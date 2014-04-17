require 'dm-migrations'
require 'dm-serializer'
require 'dm-constraints'

DataMapper::Property::String.length(255)

class Peptide
    include DataMapper::Resource
    property :id,               Serial
    property :sequence,         String, :key => true
    
    has n, :datasets, :through => :datasetpeptide
    belongs_to :basicpeptide
end

class Basicpeptide
    include DataMapper::Resource
    property :id,               Serial
    property :sequence,         String, :key => true
    
    has n, :peptides
end

class DatasetPeptide
    include DataMapper::Resource
    property :id,               Serial
    
    belongs_to :peptide
    belongs_to :dataset
end

class DatasetProtein
    include DataMapper::Resource
    property :id,               Serial
    
    belongs_to :protein
    belongs_to :dataset
end

class Dataset
    include DataMapper::Resource
    property :id,               Serial
    property :name,             String
    
    has n, :peptides, :through => :datasetpeptide
    has n, :proteins, :through => :datasetprotein
end

class Protein
    include DataMapper::Resource
    property :id,               Serial
    property :name,             String
    
    has n, :datasets, :through => :datasetprotein
end


DataMapper.finalize
Peptide.auto_migrate! unless Peptide.storage_exists?
Dataset.auto_migrate! unless Dataset.storage_exists?
Protein.auto_migrate! unless Protein    .storage_exists?
DatasetPeptide.auto_migrate! unless DatasetPeptide.storage_exists?
DatasetProtein.auto_migrate! unless DatasetProtein.storage_exists?
DataMapper.auto_upgrade!

