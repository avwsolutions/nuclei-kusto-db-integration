#!/usr/bin/env python3

import logging
import json
import os
import sys

from typing import List, MutableMapping, cast
from azure.core.exceptions import HttpResponseError
from azure.identity import DefaultAzureCredential
from azure.monitor.ingestion import LogsIngestionClient

# Enable Debug logging by setting this to True
debug = False
logger = logging.getLogger('azure.monitor.ingestion')
if debug: logger.setLevel(logging.DEBUG)

handler = logging.StreamHandler(stream=sys.stdout)
logger.addHandler(handler)

endpoint = os.environ["DATA_COLLECTION_ENDPOINT"]
rule_id = os.environ['LOGS_DCR_RULE_ID']
stream_name = os.environ["LOGS_DCR_STREAM_NAME"]

credential = DefaultAzureCredential()
client = LogsIngestionClient(endpoint=endpoint, credential=credential, logging_enable=True)
input_data: List[MutableMapping[str, str]] = sys.stdin.read().strip().split('\n')

logs = [json.loads(item) for item in input_data]

if debug: print("Parsed logs: " + logs)

try:
    client.upload(rule_id=rule_id, stream_name=stream_name, logs=logs, logging_enable=True)
except HttpResponseError as e:
    print(f"Upload failed: {e}")