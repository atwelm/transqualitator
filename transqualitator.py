#!/usr/bin/env python3
import subprocess
from enum import Enum

import ffmpeg

METRICS_FILE = 'transcoding_metrics.csv'


class Codec(Enum):
    NVENC_H264 = ('h264_nvenc')
    NVENC_HEVC = ('hevc_nvenc')

    def __init__(self, ffmpeg_param: str):
        self.ffmpeg_param = ffmpeg_param


class Source(Enum):
    BASIC = ('test.ts')

    def __init__(self, filepath: str):
        self.filepath = filepath


class Execution:
    def __init__(self, source: Source, codec: Codec, bitrate: int):
        self.source = source
        self.codec = codec
        self.bitrate = bitrate
        self.quality_score = None
        self.output_base_name = '-'.join([source.filepath.split('.')[0], codec.name, str(bitrate)]) + '.mp4'
        self.output_filename = self.output_base_name + '.mp4'
        self.metrics_filename = self.output_base_name + '-metrics.json'

    def transcode(self):
        # TODO: Add Bitrate
        ffmpeg.input(self.source.filepath).output(self.output_filename, vcodec=self.codec.ffmpeg_param).run()

    def compute_metrics(self):
        # TODO: Use the proper Python API
        cmd = ['ffmpeg', '-i', self.output_filename, '-i', self.source.filepath, '-filter_complex',
               'libvmaf=psnr=true:log_path=' + self.metrics_filename + '.json:log_fmt=json:n_threads=8',
               '-f', 'null', '-']
        subprocess.run(cmd)


def main():
    execution = Execution(Source.BASIC, Codec.NVENC_H264, 2500)
    execution.transcode()
    execution.compute_metrics()


if __name__ == '__main__':
    main()
