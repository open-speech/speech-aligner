# speech-aligner

### Chinese readme：

> speech-aligner，是一个从“人声语音”及其“语言文本”，产生音素级别时间对齐标注的工具。

### 示例

```bash
# 调用 bin，输入语音列表和文本、输出对齐结果
./bin/speech-aligner --config=egs/cn_phn/conf/align.conf egs/cn_phn/data/wav.scp egs/cn_phn/data/text egs/cn_phn/data/out.ali
# 查看输出对齐结果，包含: 文件名，音素时间起点(秒) 音素时间终点(秒) 音素
cat egs/cn_phn/data/text egs/cn_phn/data/out.ali
BAC009S0002W0123
0.000 0.025 y
0.025 0.460 e_3
0.460 0.850 sil
0.850 0.985 ch
0.985 1.095 eng_2
...
2.655 2.735 zh
2.735 2.900 ong_1
2.900 2.960 d
2.960 3.665 ing_1
3.665 3.845 sil
.
```

### 编译

- 预先准备：

  - cmake >= 3.0
  - 有如下blas接口数学库之一：
    - atlas
      - ubuntu安装: `sudo apt-get install libatlas3-base`
    - mkl
      - 建议在conda安装的python虚拟环境中：`conda install mkl`
    - OSX系统（Darwin）自带Accelerate framework，可调过这项
    - …其他数学库，可查看`cmake/Modules/FindBLAS.cmake`，了解支持的数学库
  - 如果使用g++编译，则g++ >= 5.0（std::wstring_convert需要）

- cmake编译

  ```bash
  git clone .../speech-aligner.git
  mkdir build && cd build
  cmake ..
  make -j
  ```

- 编译结果

  - bin/speech-aligner: 二进制可执行文件，
    - 配置：支持通过配置文件和命令行读取参数，建议使用如`--config=egs/cn_phn/conf/align.conf`
    - 输入：音频列表、对应的文本列表（见egs/cn_phn/data）
    - 输出：音素时间对齐标注

### 应用场景和示例

- 研究：
  - 为TTS产生音素时间标注的训练数据
    - egs/cn_phn
- 工程：
  - 歌词对齐
    - egs/cn_lyric [todo]
  - 字幕对齐
    - egs/cn_subtitle [todo]
- for fun:
  - 鬼畜
    - egs/cn_gc [todo]

### 关于

- 该工程基于著名语音开源项目[**kaldi**](https://github.com/kaldi-asr/kaldi)，copyright遵循原项目。
- 示例egs/cn_phn中，使用的音素列表，来自另一个中文词典开源项目[**DaCiDian**](https://github.com/aishell-foundation/DaCiDian)。

------

### English readme：

> speech-aligner, is a tool that generate phoneme-level alignment between human speech and its transcription

### Usage example

```bash
# call the bin，with speech and transcript as inputs
./bin/speech-aligner --config=egs/cn_phn/conf/align.conf egs/cn_phn/data/wav.scp egs/cn_phn/data/text egs/cn_phn/data/out.ali
# check the output alignment, include: filename, phoneme and its start/end time
cat egs/cn_phn/data/text egs/cn_phn/data/out.ali
BAC009S0002W0123
0.000 0.025 y
0.025 0.460 e_3
0.460 0.850 sil
0.850 0.985 ch
0.985 1.095 eng_2
...
2.655 2.735 zh
2.735 2.900 ong_1
2.900 2.960 d
2.960 3.665 ing_1
3.665 3.845 sil
.
```

### Compile

- requirements

  - cmake >= 3.0
  - one of blas math lib:
    - atlas
      - ubuntu: `sudo apt-get install libatlas3-base`
    - mkl
      - If in conda, to install mkl: `conda install mkl`
    - Accelerate framework(Darwin)
    - ...

- cmake

  ```bash
  git clone .../speech-aligner.git
  mkdir build && cd build
  cmake ..
  make -j
  ```

- results

  - bin/speech-aligner: a binary executable file, with arguments:
    - configuration: through config file (recommendation, e.g.: --config=egs/cn_phn/conf/align.conf) or command line 
    - inputs: the wav list and the correspoing transcription list (e.g. egs/cn_phn/data )
    - output: the result alignment

### Applications

- for research:
  - generate training data for TTS
    - egs/cn_phn: generate chinese phoneme alignment
- for engineering:
  - align lyric 
    - egs/cn_lyric [todo]
  - align subtitle
    - egs/cn_subtitle[todo]
- for fun:
  - きちく 
    - egs/cn_gc [todo]

### About

- This project is based on a great speech open-source project [**kaldi**](https://github.com/kaldi-asr/kaldi).
- The phonemes used in the environment: egs/cn_phn, come from a chinese dictionary open-source project [**DaCiDian**](https://github.com/aishell-foundation/DaCiDian).