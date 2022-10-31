# -*- coding: utf-8 -*-

from cpt.packager import ConanMultiPackager

if __name__ == "__main__":
    builder = ConanMultiPackager(username="jmuelbert")
    builder.add_common_builds()
    builder.run()
