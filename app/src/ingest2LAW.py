#!/usr/bin/env python3

import logging
import json
import sys

from envparse import env
from typing import List, MutableMapping, cast
from azure.core.exceptions import HttpResponseError
from azure.identity import DefaultAzureCredential
from azure.monitor.ingestion import LogsIngestionClient

debug = False 
logger = logging.getLogger('azure.monitor.ingestion')
if debug: logger.setLevel(logging.DEBUG)

# Configure a console output
handler = logging.StreamHandler(stream=sys.stdout)
logger.addHandler(handler)

endpoint = env('DATA_COLLECTION_ENDPOINT')
rule_id = env('LOGS_DCR_RULE_ID')
stream_name = env('LOGS_DCR_STREAM_NAME')

credential = DefaultAzureCredential()
client = LogsIngestionClient(endpoint=endpoint, credential=credential, logging_enable=True)
input_data: List[MutableMapping[str, str]] = sys.stdin.read().strip().split('\n')

if debug: print("Received data: " + str(input_data))

try:
    logs = [json.loads(item) for item in input_data]
except IndexError as e:
    print(f"Possible empty or corrupted list received: {e}")

if debug: print("Parsed logs: " + str(logs))

try:
    client.upload(rule_id=rule_id, stream_name=stream_name, logs=logs, logging_enable=True)
except HttpResponseError as e:
    print(f"Upload failed: {e}")