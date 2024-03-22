# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from abc import ABC, abstractmethod
from typing import List

import numpy as np

from pet.utils import InputFeatures, InputExample, PLMInputFeatures
from pet.pvp import PVP, PVPS


class Preprocessor(ABC):
    """
    A preprocessor that transforms an :class:`InputExample` into a :class:`InputFeatures` object so that it can be
    processed by the model being used.
    """

    def __init__(self, wrapper, task_name, pattern_id: int = 0, verbalizer_file: str = None):
        """
        Create a new preprocessor.

        :param wrapper: the wrapper for the language model to use
        :param task_name: the name of the task
        :param pattern_id: the id of the PVP to be used
        :param verbalizer_file: path to a file containing a verbalizer that overrides the default verbalizer
        """
        self.wrapper = wrapper
        self.pvp = PVPS[task_name](self.wrapper, pattern_id, verbalizer_file)  # type: PVP
        
        # Initialize a label mapping dictionary where label names are mapped to their corresponding indices in the list of labels.
        self.label_map = {label: i for i, label in enumerate(self.wrapper.config.label_list)}

    @abstractmethod
    def get_input_features(self, example: InputExample, labelled: bool, priming: bool = False,
                           **kwargs) -> InputFeatures:
        """Convert the given example into a set of input features"""
        pass


class MLMPreprocessor(Preprocessor):
    """Preprocessor for models pretrained using a masked language modeling objective (e.g., BERT)."""

    def get_input_features(self, example: InputExample, labelled: bool, priming: bool = False,
                           **kwargs) -> InputFeatures:
        if priming:
            # Encode data with priming data
            input_ids, token_type_ids = self.pvp.encode(example, priming=True)
            priming_data = example.meta['priming_data']  # List of InputExamples

            priming_input_ids = []
            # Encode each priming example
            for priming_example in priming_data:
                pe_input_ids, _ = self.pvp.encode(priming_example, priming=True, labelled=True)
                priming_input_ids += pe_input_ids

            # Add priming data to the input_ids
            input_ids = priming_input_ids + input_ids
            token_type_ids = self.wrapper.tokenizer.create_token_type_ids_from_sequences(input_ids)
            input_ids = self.wrapper.tokenizer.build_inputs_with_special_tokens(input_ids)
        else:
            # Encode the input example
            input_ids, token_type_ids = self.pvp.encode(example)

        # Create an attention mask, which marks which tokens to attend to
        attention_mask = [1] * len(input_ids)

        # Calculate the padding length to reach the maximum sequence length
        padding_length = self.wrapper.config.max_seq_length - len(input_ids)

        if padding_length < 0:
            raise ValueError(f"Maximum sequence length is too small, got {len(input_ids)} input ids")

        # Pad the input_ids, attention_mask, and token_type_ids to the maximum sequence length
        input_ids = input_ids + ([self.wrapper.tokenizer.pad_token_id] * padding_length)
        attention_mask = attention_mask + ([0] * padding_length)
        token_type_ids = token_type_ids + ([0] * padding_length)

        # Ensure that the lengths of input_ids, attention_mask, and token_type_ids match the maximum sequence length
        assert len(input_ids) == self.wrapper.config.max_seq_length
        assert len(attention_mask) == self.wrapper.config.max_seq_length
        assert len(token_type_ids) == self.wrapper.config.max_seq_length

        # Map the example's label to the label_map or set it to -100 if not available
        label = self.label_map[example.label] if example.label is not None else -100

        # Get logits from the example or set them to -1 if not available
        logits = example.logits if example.logits else [-1]

        if labelled:
            # Generate MLM (Masked Language Modeling) labels
            mlm_labels = self.pvp.get_mask_positions(input_ids)

            if self.wrapper.config.model_type == 'gpt2':
                # Shift labels to the left by one (specific to GPT-2 model)
                mlm_labels.append(mlm_labels.pop(0))
        else:
            # Set MLM labels to -1 for unlabelled examples
            mlm_labels = [-1] * self.wrapper.config.max_seq_length

        return InputFeatures(input_ids=input_ids, attention_mask=attention_mask, token_type_ids=token_type_ids,
                             label=label, mlm_labels=mlm_labels, logits=logits, idx=example.idx)

class PLMPreprocessor(MLMPreprocessor):
    """Preprocessor for models pretrained using a permuted language modeling objective (e.g., XLNet)."""

    def get_input_features(self, example: InputExample, labelled: bool, priming: bool = False,
                           **kwargs) -> PLMInputFeatures:
        # Call the parent class's get_input_features method and store the result in input_features
        input_features = super().get_input_features(example, labelled, priming, **kwargs)
        input_ids = input_features.input_ids

        # Specify the number of masks (usually 1, as PLMPreprocessor supports only one mask)
        num_masks = 1

        # Create a binary permutation mask for the input_ids
        perm_mask = np.zeros((len(input_ids), len(input_ids)), dtype=np.float)
        label_idx = input_ids.index(self.pvp.mask_id)
        perm_mask[:, label_idx] = 1  # Set the masked token as not seen by other tokens

        # Create a target mapping for the masked token
        target_mapping = np.zeros((num_masks, len(input_ids)), dtype=np.float)
        target_mapping[0, label_idx] = 1.0  # Mark the location of the masked token

        # Return PLMInputFeatures by combining the perm_mask, target_mapping, and other attributes from input_features
        return PLMInputFeatures(perm_mask=perm_mask, target_mapping=target_mapping, **input_features.__dict__)


class SequenceClassifierPreprocessor(Preprocessor):
    """Preprocessor for a regular sequence classification model."""

    def get_input_features(self, example: InputExample, **kwargs) -> InputFeatures:
        # Attempt to get sequence classifier inputs from the task helper, if available
        inputs = self.wrapper.task_helper.get_sequence_classifier_inputs(example) if self.wrapper.task_helper else None

        # If task helper is not available or doesn't provide inputs, use the tokenizer to encode the text
        if inputs is None:
            print("This is example.text_a",example.text_a)
            print("This is example.text_b",example.text_b)
        
            inputs = self.wrapper.tokenizer.encode_plus(
                example.text_a if example.text_a else None,
                example.text_b if example.text_b else None,
                add_special_tokens=True,
                max_length=self.wrapper.config.max_seq_length,
            )
        
        # Extract input_ids and token_type_ids from the provided inputs
        input_ids, token_type_ids = inputs["input_ids"], inputs.get("token_type_ids")

        # Initialize attention_mask with 1 for all input_ids
        attention_mask = [1] * len(input_ids)
        
        # Calculate padding length
        padding_length = self.wrapper.config.max_seq_length - len(input_ids)

        # Pad input_ids, attention_mask, and token_type_ids to match max_seq_length
        input_ids = input_ids + ([self.wrapper.tokenizer.pad_token_id] * padding_length)
        attention_mask = attention_mask + ([0] * padding_length)
        
        # If token_type_ids are not provided, set them to 0 for the entire sequence
        if not token_type_ids:
            token_type_ids = [0] * self.wrapper.config.max_seq_length
        else:
            token_type_ids = token_type_ids + ([0] * padding_length)
        
        # Initialize mlm_labels with -1 for all input_ids
        mlm_labels = [-1] * len(input_ids)

        # Assert the lengths of input_ids, attention_mask, and token_type_ids match max_seq_length
        assert len(input_ids) == self.wrapper.config.max_seq_length
        assert len(attention_mask) == self.wrapper.config.max_seq_length
        assert len(token_type_ids) == self.wrapper.config.max_seq_length

        # Map the label to its index using label_map or set to -100 if label is None
        label = self.label_map[example.label] if example.label is not None else -100
        
        # Use provided logits or set to -1 if logits are not available
        logits = example.logits if example.logits else [-1]

        # Return InputFeatures object with the prepared input features
        return InputFeatures(input_ids=input_ids, attention_mask=attention_mask, token_type_ids=token_type_ids,
                             label=label, mlm_labels=mlm_labels, logits=logits, idx=example.idx)
