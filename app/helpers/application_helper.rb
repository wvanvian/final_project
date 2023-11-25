module ApplicationHelper
  def files_in_directory(dir)
    Dir.children(Rails.root.join('public', dir)).map { |filename| [filename, filename] }
  end
end
