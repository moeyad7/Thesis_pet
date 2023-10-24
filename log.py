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

"""
This file contains basic logging logic.
"""
import logging

names = set()


# Define a function to set up a custom logger
def __setup_custom_logger(name: str) -> logging.Logger:
    # Get the root logger (the main logger for the application) and clear any existing handlers
    # Handlers are responsible for determining what happens to log records (log messages) after they have been created by loggers.
    root_logger = logging.getLogger()
    root_logger.handlers.clear()

    # Create a log message formatter
    formatter = logging.Formatter(fmt='%(asctime)s - %(levelname)s - %(module)s - %(message)s')

    # Add the given name to a set of logger names
    names.add(name)

    # Create a log handler that sends log messages to the console (stdout)
    handler = logging.StreamHandler()
    handler.setFormatter(formatter)

    # Create a new logger with the specified name
    logger = logging.getLogger(name)
    logger.setLevel(logging.INFO)  # Set the logging level to INFO
    logger.addHandler(handler)  # Attach the handler to the logger
    return logger


def get_logger(name: str) -> logging.Logger:
    # if the logger already exists, return it else create a new logger
    if name in names:
        return logging.getLogger(name)
    else:
        return __setup_custom_logger(name)
