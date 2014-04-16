

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
require './controller_peptide'


setting_initialize();



get '/' do
    "PROXI Demo"
end

get '/peptide/all' do
    puts Peptide.all()
    puts "ALL"
    return Peptide.all.to_json
end

get '/peptide/query/:peptide' do
    query_peptide = params[:peptide]
    peptide_object = Basicpeptide.first(:sequence => query_peptide)
    
    if peptide_object == nil
        return "{}"
    end
    
    return peptide_object.peptides.datasets.to_json()
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
