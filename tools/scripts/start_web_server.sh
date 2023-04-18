#!/bin/bash

cd /web_server/
export FLASK_APP=main.py
flask run --host=0.0.0.0 # acces remot