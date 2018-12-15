#!/usr/bin/env bash

# Copyright 2018 open-speech songmeixu (songmeixu@outlook.com)

set -e

stage=1

. ./path.sh
. ./utils/parse_options.sh

# generate alignments
if [ $stage -le 1 ]; then
  speech-aligner --config=conf/align.conf data/wav.scp data/text data/out.ali || exit 1;
fi

exit 0;
