require 'dm-migrations'
require 'dm-serializer'
require 'dm-constraints'

DataMapper::Property::String.length(255)

class Datasetpeptidespectrummatch
    include DataMapper::Resource
    property :id,               Serial
    property :filename,         String
    property :scan,             String
    property :tabfile,          String
    
    belongs_to :DatasetPeptide
end

class Peptide
    include DataMapper::Resource
    property :id,               Serial
    property :sequence,         String, :key => true, :index => true
    
    has n, :datasets, :through => :datasetpeptide
    belongs_to :basicpeptide
end

class Basicpeptide
    include DataMapper::Resource
    property :id,               Serial
    property :sequence,         String, :key => true, :index => true
    
    has n, :peptides
    has n, :datasets, :through => :BasicPeptideDataset
end

class DatasetPeptide
    include DataMapper::Resource
    property :id,               Serial
    
    #has n, :datasetpeptidespectrummatch
    belongs_to :peptide
    belongs_to :dataset
    
end

class BasicpeptideDataset
    include DataMapper::Resource
    property :id,               Serial
    
    belongs_to :basicpeptide
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
    
    has n, :basicpeptides, :through => :datasetbasicpeptide
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
Datasetpeptidespectrummatch.auto_migrate! unless Datasetpeptidespectrummatch.storage_exists?
DataMapper.auto_upgrade!

