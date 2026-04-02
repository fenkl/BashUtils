#!/bin/bash

find . -iname "*.py" | xargs grep -E "^(import |from .+ import)"

