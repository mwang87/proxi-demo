require 'dm-migrations'
require 'dm-serializer'
require 'dm-constraints'

DataMapper::Property::String.length(255)

class Modification
    include DataMapper::Resource
    property :id,               Serial
    property :name,             String
    
    has n, :variants, :through => :ModificationVariant
    has n, :peptides, :through => :ModificationPeptide
end

class ModificationVariant
    include DataMapper::Resource
    property :id,               Serial
    property :location,         Integer

    belongs_to :modification
    belongs_to :variant
end

class ModificationPeptide
    include DataMapper::Resource
    property :id,               Serial
    
    belongs_to :modification
    belongs_to :peptide
end

class Datasetvariantspectrummatch
    include DataMapper::Resource
    property :id,               Serial
    property :filename,         String
    property :scan,             String
    property :tabfile,          String
    
    belongs_to :DatasetVariant
    belongs_to :DatasetProtein
end

class Variant
    include DataMapper::Resource
    property :id,               Serial
    property :sequence,         String
    
    has n, :datasets, :through => :datasetvariant
    has n, :modifications, :through => :modificationvariant
    belongs_to :peptide
end

class Peptide
    include DataMapper::Resource
    property :id,               Serial
    property :sequence,         String, :key => true, :index => true
    
    has n, :variants
    has n, :DatasetPeptide
    has n, :datasets, :through => :DatasetPeptide
    has n, :modifications, :through => :modificationpeptide
end

class DatasetVariant
    include DataMapper::Resource
    property :id,               Serial
    
    #has n, :datasetpeptidespectrummatch
    belongs_to :variant
    belongs_to :dataset
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
    
    has n, :DatasetPeptide
    has n, :DatasetVariant
    has n, :DatasetProtein

    has n, :peptide, :through => :DatasetPeptide
    has n, :variants, :through => :datasetvariant
    has n, :proteins, :through => :datasetprotein
end

class Protein
    include DataMapper::Resource
    property :id,               Serial
    property :name,             String
    
    has n, :DatasetProtein
    has n, :datasets, :through => :datasetprotein
end




DataMapper.finalize
Peptide.auto_migrate! unless Peptide.storage_exists?
Variant.auto_migrate! unless Variant.storage_exists?
Dataset.auto_migrate! unless Dataset.storage_exists?
Protein.auto_migrate! unless Protein.storage_exists?
Modification.auto_migrate! unless Modification.storage_exists?
ModificationVariant.auto_migrate! unless ModificationVariant.storage_exists?
DatasetVariant.auto_migrate! unless DatasetVariant.storage_exists?
DatasetProtein.auto_migrate! unless DatasetProtein.storage_exists?
Datasetvariantspectrummatch.auto_migrate! unless Datasetvariantspectrummatch.storage_exists?
DataMapper.auto_upgrade!

