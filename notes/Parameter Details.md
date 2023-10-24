# `cli.py` Parameter Details
## **Required Parameters:**

- `method`: This is the training method to use, and you must choose one from 'pet', 'ipet', or 'sequence_classifier'. It determines the approach used for training.

- `data_dir`: The input data directory, where the data files for the task are stored. This is where the training data is located.

- `model_type`: The type of the pretrained language model to use. You can choose from various options provided.

- `model_name_or_path`: The path to the pre-trained model or a shortcut name that refers to a specific pre-trained model.

- `task_name`: The name of the task that you want to train or evaluate on. Choose from predefined task names.

- `output_dir`: The output directory where the model predictions and checkpoints will be saved during training.

## **PET-Specific Optional Parameters:**

- `wrapper_type`: This determines the type of language model wrapper to use, such as 'mlm' for a masked language model like BERT or 'plm' for a permuted language model like XLNet (only for PET).

- `pattern_ids`: These are the ids of the PVPs (Pattern-Text-Verbalizer Pairs) to be used (only for PET).

- `lm_training`: If set to true, it indicates whether to use language modeling as an auxiliary task (only for PET).

- `alpha`: It's a weighting term for the auxiliary language modeling task (only for PET).

- `temperature`: This is the temperature used for combining PVPs (only for PET).

- `verbalizer_file`: Path to a file that can override default verbalizers (only for PET).

- `reduction`: It's the strategy for merging predictions from multiple PET models, with options for uniform weighting or weighting based on train set accuracy.

- `decoding_strategy`: Determines the decoding strategy for PET with multiple masks (only for PET).

- `no_distillation`: If set to true, it means no distillation is performed (only for PET).

- `pet_repetitions`: The number of times to repeat PET training and testing with different seeds.

- `pet_max_seq_length`: The maximum total input sequence length after tokenization for PET. Sequences longer than this will be truncated, and sequences shorter will be padded.

- `pet_per_gpu_train_batch_size`: Batch size per GPU/CPU for PET training.

- `pet_per_gpu_eval_batch_size`: Batch size per GPU/CPU for PET evaluation.

- `pet_per_gpu_unlabeled_batch_size`: Batch size per GPU/CPU for auxiliary language modeling examples in PET.

- `pet_gradient_accumulation_steps`: Number of updates steps to accumulate before performing a backward/update pass in PET.

- `pet_num_train_epochs`: Total number of training epochs to perform in PET.

- `pet_max_steps`: If greater than 0, it sets the total number of training steps to perform in PET and overrides the num_train_epochs.

## **SequenceClassifier-Specific Optional Parameters (also used for the final PET classifier):**

- `sc_repetitions`: The number of times to repeat sequence classifier training and testing with different seeds.

- `sc_max_seq_length`: The maximum total input sequence length after tokenization for sequence classification.

- `sc_per_gpu_train_batch_size`: Batch size per GPU/CPU for sequence classifier training.

- `sc_per_gpu_eval_batch_size`: Batch size per GPU/CPU for sequence classifier evaluation.

- `sc_per_gpu_unlabeled_batch_size`: Batch size per GPU/CPU for unlabeled examples used for distillation.

- `sc_gradient_accumulation_steps`: Number of updates steps to accumulate before performing a backward/update pass for sequence classifier training.

- `sc_num_train_epochs`: Total number of training epochs to perform for sequence classifier training.

- `sc_max_steps`: If greater than 0, it sets the total number of training steps for sequence classifier training and overrides the num_train_epochs.

## **iPET-Specific Optional Parameters:**

- `ipet_generations`: The number of generations to train (only for iPET).

- `ipet_logits_percentage`: The percentage of models to choose for annotating new training sets (only for iPET).

- `ipet_scale_factor`: The factor by which to increase the training set size per generation (only for iPET).

- `ipet_n_most_likely`: If greater than 0, in the first generation the n_most_likely examples per label are chosen even if their predicted label is different (only for iPET).

## **Other Optional Parameters:**

- `train_examples`, `test_examples`, and `unlabeled_examples`: The total number of train, test, and unlabeled examples to use. -1 equals using all examples.

- `split_examples_evenly`: If set to true, it means train examples are not chosen randomly but split evenly across all labels.

- `cache_dir`: Specifies where to store the pre-trained models downloaded from S3.

- `learning_rate`: The initial learning rate for the Adam optimizer.

- `weight_decay`: Weight decay if applied.

- `adam_epsilon`: Epsilon for Adam optimizer.

- `max_grad_norm`: The maximum gradient norm.

- `warmup_steps`: Linear warmup over warmup_steps.

- `logging_steps`: It determines how often to log updates.

- `no_cuda`: If set to true, it avoids using CUDA when available.

- `overwrite_output_dir`: If set to true, it overwrites the content of the output directory.

- `seed`: The random seed for initialization.

- `do_train`, `do_eval`, and `priming`: These are flags that indicate whether to perform training, evaluation, or priming.

- `eval_set`: Specifies whether to perform evaluation on the development or test set.