# -*- coding: utf-8 -*-
# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# http://www.sphinx-doc.org/en/master/config
"""Sphinx configuration."""
from datetime import datetime

# -- Project information -----------------------------------------------------

PROJECT = "qt_conan_boilerplate_template"
AUTHOR = "Jürgen Mülbert"
COPYRIGHT = f"2022-{datetime.now().year}, {AUTHOR}"
EXTENSIONS = [
    "sphinx.ext.autodoc",
    "sphinx.ext.furo",
]
AUTODOC_TYPEHINTS = "description"
HTML_THEME = "furo"
