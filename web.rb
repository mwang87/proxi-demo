

require 'sinatra'
require 'time'
require 'net/http'
require 'uri'
require 'json'
require 'data_mapper'
require 'dm-transactions'

require 'redis'
require 'haml'
require './settings'
require './models'
require './controllers/peptide_controller'
require './controllers/dataset_controller'
require './controllers/variant_controller'
require './controllers/protein_controller'

get '/' do
    haml :homepage
end



get '/peptide/list.json' do
    #@all_peptides = Basicpeptide.all
    page_number = 1
    if params[:page] != nil
        page_number = params[:page].to_i
    end

    results = Basicpeptide.all(:offset => (page_number - 1) * PAGINATION_SIZE , :limit => PAGINATION_SIZE)

    return results.to_json
end




get '/peptide/querymod/:peptide' do
    query_peptide = params[:peptide]
    peptide_object = Basicpeptide.first(:sequence => query_peptide)
    
    if peptide_object == nil
        return "{}"
    end
    
    return peptide_object.peptides.to_json()
end

get '/protein/all' do
    @all_proteins = Protein.all
    
    haml :protein_all
end

get '/protein/all.json' do
    return Protein.all.to_json
end

get '/protein/query/:protein' do
    query_protein = params[:protein]
    protein_object = Protein.first(:name => query_protein)
    
    if protein_object == nil
        return "{}"
    end
    
    return protein_object.datasets.to_json()
end

get '/peptide/create' do
    haml :peptidecreatelink
end

post '/peptide/create' do
    puts params
    peptide = params[:peptide]
    dataset = params[:dataset]
    
    peptide_db = get_create_peptide(peptide)
    puts peptide_db
    dataset_db = get_create_dataset(dataset)
    puts dataset_db
    
    join_db = create_dataset_peptide_link(peptide_db, dataset_db)
    
    if(join_db == nil)
        return "DNS"
    end
    
    return "SAVED"
end

get '/protein/create' do
    haml :proteincreatelink
end

post '/protein/create' do
    puts params
    protein = params[:protein]
    dataset = params[:dataset]
    
    protein_db = get_create_protein(protein)
    dataset_db = get_create_dataset(dataset)
    
    join_db = create_dataset_protein_link(protein_db, dataset_db)
    
    if(join_db == nil)
        return "DNS"
    end
    
    return "SAVED"
end
