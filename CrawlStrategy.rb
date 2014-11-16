# -*- encoding: utf-8 -*-

load 'NishitokyoStrategy.rb'
load 'ComicStrategy.rb'

STRATEGY_MAPPING = {"西東京市" => NishitokyoStrategy,
                    "コミック" => ComicStrategy}.freeze
LIBRARY_NAMES = STRATEGY_MAPPING.keys.freeze
