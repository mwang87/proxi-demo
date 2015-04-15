
get '/variant/list' do
    page_number = 1
    if params[:page] != nil
        page_number = params[:page].to_i
    end

    #Determining next and prev page
    if page_number == 1
        @next_page = page_number + 1
        @previous_page = nil
    else
        @next_page = page_number + 1
        @previous_page = page_number - 1
    end

    @variants = Peptide.all(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    haml :variant_all
end

get '/variant/:variant/dataset/list' do
	variant_seq = params[:variant]
    peptide_object = Peptide.first(:sequence => variant_seq)
    
    @datasets = peptide_object.datasets
    @peptide = variant_seq
    haml :dataset_all
end