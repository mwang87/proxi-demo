
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
    haml :variant_datasets
end


get '/variant/:variant/dataset/:dataset/psm/list' do
	variant_db = Peptide.first(:sequence => params[:variant])
	dataset_db = Dataset.first(:id => params[:dataset])

	#variant_dataset_db = DatasetPeptide.first(:peptide => variant_db, :dataset => dataset_db)

	#psms = 

	@psms = Datasetpeptidespectrummatch.all(:DatasetPeptide => {:peptide => variant_db, :dataset => dataset_db})

	haml :psms_all
end

#List all the variants of a given peptide
get '/peptide/:peptide/variant/list' do
    page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    basic_peptide = Basicpeptide.first(:sequence => params[:peptide])
    @variants = basic_peptide.peptides(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    haml :variant_all
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
