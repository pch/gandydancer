module SharedHelper
  def page_title(title)
    content_for(:page_title) { title }
  end

  def body_class(options = {})
    extra_body_classes_symbol = options[:extra_body_classes_symbol] || :extra_body_classes
    qualified_controller_name = controller.controller_path.gsub('/','-')
    basic_body_class = "#{qualified_controller_name} #{qualified_controller_name}-#{controller.action_name}"

    if content_for?(extra_body_classes_symbol)
      [basic_body_class, content_for(extra_body_classes_symbol)].join(' ')
    else
      basic_body_class
    end
  end

  def canonical(url)
    content_for(:canonical) { url }
  end

  # Used as a link_to_unless_current replacement.
  # The difference is that when url == current_url, it renders
  # the contents of &block (unlinked)
  #
  # Name could be better ...
  def custom_link_to_unless(*args,&block)
    args.insert 1, capture(&block) if block_given?
    link_to_unless *args
  end

  def user_facing_flashes
    flash.to_hash.slice("alert", "error", "notice", "success")
  end
end
