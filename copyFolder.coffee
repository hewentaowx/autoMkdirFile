fs = require 'fs'
path = require 'path'

# 利用readdir读取传入路径下的所有目录
readdir = (fromPath, toPath) ->
  fs.readdir fromPath, (err, paths) ->
    if err
      throw err
    paths.forEach (eachPath) ->
      _src = path.join "#{fromPath}", "#{eachPath}"
      _dst = path.join "#{toPath}", "#{eachPath}"
      # 计算相对路径
      num = (_src.split '/').length - 1
      prefix = [1...num].reduce (r) ->
        "../#{r}"
      , ''
      stat _src, _dst, prefix

# 判断处理的是一个文件还是一个目录
stat = (_src, _dst, prefix) ->
  fs.stat _src, (err, st) ->
    if err
      throw err
    # 判断是否为文件
    if st.isFile()
      # 创建读取流 读取模板内容用于填充
      text = fs.readFileSync('./template.coffee').toString()
      text = text.replace(/targetPath/g, "#{prefix}#{_src}")
      # 创建写入流 将.coffee后缀的文件改为.js的文件
      reg = /.coffee/gi
      new_dst = _dst.replace(reg, '.js')
      writeable = fs.createWriteStream new_dst
      fs.writeFile "#{new_dst}", text, (err) ->
        if err
          throw err
    else if st.isDirectory()
      # 如果是目录的话 利用递归调用自身
      exists _src, _dst, copy
    return
  return

# 判断文件是否存在
exists = (src, dst, callback) ->
  fs.exists dst, (exists) ->
    # 已存在
    if exists
      callback src, dst
    else
      fs.mkdir dst, ->
        callback src, dst
        return
    return
  return

# copy
copy = (fromPath, toPath) ->
  readdir fromPath, toPath

# 文件复制
copyFileFolder = (fromPath, toPath) ->
  copy fromPath, toPath
  exists fromPath, toPath, copy

# 调用复制目录copyFileFolder接口传入 fromPath 和 toPath 在此传参
copyFileFolder './src', './'