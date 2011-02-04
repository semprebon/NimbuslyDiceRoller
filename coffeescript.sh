#!/bin/bash

MINIWIKI_HOME=.
date >$MINIWIKI_HOME/coffeescript.log
$MINIWIKI_HOME/cf.sh $MINIWIKI_HOME/coffeescript/*.coffee
$MINIWIKI_HOME/cf.sh $MINIWIKI_HOME/test/coffeescript/*.coffee
