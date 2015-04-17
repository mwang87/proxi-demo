
#List all the basic peptides
get '/peptide/list' do
    #@all_peptides = Basicpeptide.all
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


    @all_peptides = Peptide.all(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    haml :peptide_all
end



#List all the variants of a given peptide
get '/peptide/:peptide/variant/list' do
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

    basic_peptide = Basicpeptide.first(:sequence => params[:peptide])
    @variants = basic_peptide.peptides(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    haml :variant_all
end

#List all the basic peptides in a dataset
get '/peptide/:peptide/dataset/list' do
    query_peptide = params[:peptide]
    peptide_object = Basicpeptide.first(:sequence => query_peptide)
    
    if peptide_object == nil
        return "{}"
    end
    
    @datasets = peptide_object.datasets
    @peptide = query_peptide
    haml :peptide_datasets
end

#For each basic peptide, and dataset, list all the variants
get '/peptide/:peptide/dataset/:dataset/variants/list' do
    peptide_db = Basicpeptide.first(:sequence => params[:peptide])
    dataset_db = Dataset.first(:name => params[:dataset])
    
    join_dataset_peptide = BasicpeptideDataset.first(:dataset => dataset_db, :basicpeptide => peptide_db)
    
    #@variants = Peptide.all(:basicpeptide => {:sequence => params[:peptide]}, :datasets => {:id => params[:dataset]})
    #@variants = Datasetpeptidespectrummatch.all(:DatasetPeptide => join_dataset_peptide)
    haml :variant_all
    #

    #psms.to_json()
end






