

###
# => Variant aggregation view
###
get '/variants/aggregateview' do
    @page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    protein = params[:protein]
    peptide = params[:peptide]
    modification = params[:mod]
    variant = params[:variant]

    minimum_mass = params[:mod_mass_minimum]
    maximum_mass = params[:mod_mass_maximum]

    if protein == nil
        protein = ""
    end

    if variant == nil
        variant = ""
    end

    if peptide == nil
        peptide = ""
    end

    if modification == nil
        modification = ""
    end

    if minimum_mass == nil
        minimum_mass = ""
    end

    if maximum_mass == nil
        maximum_mass = ""
    end


    #Web Rendering Code
    @variant_input = variant
    @peptide_input = peptide
    @modification_input = modification
    @protein_input = protein

    @mod_minimum = minimum_mass
    @mod_maximum = maximum_mass

    @param_string = "variant=" + CGI.escape(variant) + "&peptide=" + peptide + "&mod=" + CGI.escape(modification) + "&protein=" + @protein_input
    @param_string += "&mod_min=" + @mod_minimum + "&mod_max=" + @mod_maximum

    #@all_proteins_autocomplete = Protein.all().map(&:name)
    @all_modifications = Modification.all().map(&:name)


    #Actual Processing

    query_parameters = Hash.new
    query_parameters[:offset]  = (@page_number - 1) * PAGINATION_SIZE
    query_parameters[:limit]  = PAGINATION_SIZE

    count_parameters = Hash.new

    if peptide.length > 2
        query_peptide = "%" + peptide + "%"
        peptides_db = Peptide.all(:sequence.like => query_peptide)
        query_parameters[:peptide] = peptides_db
        count_parameters[:peptide] = peptides_db
    end

    if protein.length > 2
        protein_db = Protein.first(:name => protein)
        query_parameters[:proteinvariant] = ProteinVariant.all(:protein => protein_db)
        count_parameters[:proteinvariant] = ProteinVariant.all(:protein => protein_db)
    end

    if variant.length > 2
        query_variant = "%" + variant + "%"
        query_parameters[:sequence.like] = query_variant
        count_parameters[:sequence.like] = query_variant
    end

    if modification.length > 2
        mod_db = Modification.first(:name => modification)
        query_parameters[:modificationvariant] = ModificationPeptide.all(:modification => mod_db)
        count_parameters[:modificationvariant] = ModificationPeptide.all(:modification => mod_db)
    elsif minimum_mass.length > 0 or maximum_mass.length > 0
        mod_mass_minimum = -999
        mod_mass_maximum = 999
        if minimum_mass.length > 0
            mod_mass_minimum = minimum_mass.to_f
        end
        if maximum_mass.length > 0
            mod_mass_maximum = maximum_mass.to_f
        end
        mod_db = Modification.all(:mass.gt => mod_mass_minimum, :mass.lt => mod_mass_maximum)
        query_parameters[:modificationvariant] = ModificationVariant.all(:modification => mod_db)
        count_parameters[:modificationvariant] = ModificationVariant.all(:modification => mod_db)
    end

    @all_variants = Variant.all(query_parameters)
    @total_count = Variant.count(count_parameters)

    if (@next_page - 1) * PAGINATION_SIZE > @total_count
        @next_page = nil
    end

    haml :variant_aggregate
end


#Deprecated Views

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
