HotCocoa::Mappings.map :table_view => :NSTableView do
  
  defaults :column_resize => :uniform, :frame => DefaultEmptyRect, :layout => {}
  
  constant :column_resize, {
    :none               => NSTableViewNoColumnAutoresizing,
    :uniform            => NSTableViewUniformColumnAutoresizingStyle,
    :sequential         => NSTableViewSequentialColumnAutoresizingStyle,
    :reverse_sequential => NSTableViewReverseSequentialColumnAutoresizingStyle,
    :last_column_only   => NSTableViewLastColumnOnlyAutoresizingStyle,
    :first_column_only  => NSTableViewFirstColumnOnlyAutoresizingStyle
  }
  
  constant :grid_style, { 
    :none               => NSTableViewGridNone, 
    :vertical           => NSTableViewSolidVerticalGridLineMask, 
    :horizontal         => NSTableViewSolidHorizontalGridLineMask, 
  	:both               => NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask 
  }

  def init_with_options(table_view, options)
    table_view.initWithFrame(options.delete(:frame))
  end

  custom_methods do
    
    def data=(data_source)
      data_source = TableDataSource.new(data_source) if data_source.kind_of?(Array)
      setDataSource(data_source)
    end
    
    def data_source
      dataSource
    end
    
    def columns=(columns)
      columns.each do |column|
        addTableColumn(column)
      end
    end
    
    def column=(column)
      addTableColumn(column)
    end
    
    def auto_size
      setAutoresizingMask(NSViewHeightSizable|NSViewWidthSizable)
    end
    
    def column_resize=(style)
      setColumnAutoresizingStyle(style)
    end

    def reload 
   	  reloadData 
   	end 
   	
   	def alternating_row_background_colors=(value) 
   	  setUsesAlternatingRowBackgroundColors(value) 
   	end 
   	
   	def grid_style=(value) 
   	  setGridStyleMask(value) 
   	end
    
  end

end