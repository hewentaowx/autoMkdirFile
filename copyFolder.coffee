fs = require 'fs'
path = require 'path'

readdir = (fromPath, toPath) ->
  fs.readdir fromPath, (err, paths) ->
    if err
      throw err
    paths = check paths, ['utils']
    paths.forEach (eachPath) ->
      _src = path.join "#{fromPath}", "#{eachPath}"
      _dst = path.join "#{toPath}", "#{eachPath}"
      num = (_src.split '/').length - 1
      prefix = [1...num].reduce (r) ->
        "../#{r}"
      , './'
      stat _src, _dst, prefix

stat = (_src, _dst, prefix) ->
  fs.stat _src, (err, st) ->
    if err
      throw err
    if st.isFile()
      text = """'use strict';
        require('coffee-require/register');
        module.exports = require('targetPath');"""
      text = text.replace(/targetPath/g, "#{prefix}#{_src}")
      reg = /.coffee/gi
      new_dst = _dst.replace(reg, '.js')
      writeable = fs.createWriteStream new_dst
      fs.writeFile "#{new_dst}", text, (err) ->
        if err
          throw err
    else if st.isDirectory()
      exists _src, _dst, copy
    return
  return

exists = (src, dst, callback) ->
  fs.exists dst, (exists) ->
    if exists
      callback src, dst
    else
      fs.mkdir dst, ->
        callback src, dst
        return
    return
  return

check = (arr, params) ->
  for i in [0...params.length]
    index = arr.indexOf params[i]
    if index > -1
      arr.splice index, 1
  arr

copy = (fromPath, toPath) ->
  readdir fromPath, toPath

copyFileFolder = (fromPath, toPath) ->
  copy fromPath, toPath
  exists fromPath, toPath, copy

# 接口传入 fromPath 和 toPath 在此传参
copyFileFolder './src', './'