module Kaminari
  module ActionViewExtension
    def paginate(scope, options = {})
      paginator = Kaminari::Helpers::Paginator.new(self, options.reverse_merge(:current_page => scope.current_page, :total_pages => scope.total_pages, :per_page => scope.limit_value, :remote => false))
      paginator.output_buffer = ActionView::OutputBuffer.new
      paginator.to_s
    end
  end
end