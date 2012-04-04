def render_file(filename)
  contents = File.read(filename + ".haml")
  contents = yield contents if block_given?
  Haml::Engine.new(contents).render
end

def render_files(filenames, func = nil)
  contents = ''
  filenames.each do |filename|
    if func == nil
      contents += render_file(filename)
    else
      contents += func.call(filename, render_file(filename))
    end
  end
  return contents
end

def deck_header
  render_template('deck_header')
end

def deck_footer
  render_template('deck_footer')
end

def deck &block
  render_template 'deck', capture_haml(&block)
end

def render_template template, to_add = '', &block
  if to_add == '' && block_given?
    to_add = capture_haml(&block)
  end
  eval("$content_#{template} = to_add")
  return render_file('./templates/' + template)
end

def slides(filenames, end_slide = true)
  filenames = filenames.collect{|f| './slides/' + f}
  filenames.push('./templates/end_slide') if end_slide
  render_files filenames, lambda {|filename, content|
    $id = bash_ready(filename.gsub(/^.\/(slides|templates)\//, ''))
    render_template 'slide', content
  }
end

def bash_ready str
  str.gsub(/ /, '_')
end