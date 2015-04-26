require 'dm-migrations'
require 'dm-serializer'
require 'dm-constraints'

DataMapper::Property::String.length(255)

class Peptide
    include DataMapper::Resource
    property :id,               Serial
    property :sequence,         String

    has n, :modifications, :through => :modificationpeptide
    has n, :proteins, :through => :peptideprotein
    has n, :datasets, :through => :datasetpeptide
    has n, :peptidespectrummatch
end

class Dataset
    include DataMapper::Resource
    property :id,               Serial
    property :name,             String
    property :task_id,          String

    has n, :peptides, :through => :datasetpeptide
    has n, :proteins, :through => :datasetprotein
    has n, :modifications, :through => :datasetmodification
    has n, :peptidespectrummatch
end

class DatasetPeptide
    include DataMapper::Resource
    property :id,               Serial
    property :sequence,         String      #For Fast Querying

    belongs_to :peptide
    belongs_to :dataset
end

class DatasetModification
    include DataMapper::Resource
    property :id,               Serial

    belongs_to :dataset
    belongs_to :modification
end

class Protein
    include DataMapper::Resource
    property :id,               Serial
    property :name,             String
end


class PeptideProtein
    include DataMapper::Resource
    property :id,               Serial
    property :sequence,         String      #For Fast Querying

    belongs_to :peptide
    belongs_to :protein
end

class Modification
    include DataMapper::Resource
    property :id,               Serial
    property :name,             String

    has n, :proteins, :through => :modificationprotein
    has n, :peptides, :through => :modificationpeptide

end

class ModificationPeptide
    include DataMapper::Resource
    property :id,               Serial

    belongs_to :peptide
    belongs_to :modification
end

class Variant
    include DataMapper::Resource
    property :id,               Serial
    property :sequence,         String

    belongs_to :peptide

    has n, :modifications, :through => :modificationvariant
    has n, :peptidespectrummatch
end

class ModificationVariant
    include DataMapper::Resource
    property :id,               Serial
    property :location,         Integer

    belongs_to :modification
    belongs_to :variant
end

class Protein
    include DataMapper::Resource
    property :id,               Serial
    property :name,             String

    has n, :peptides, :through => :peptideprotein
    has n, :modifications, :through => :modificationprotein
    has n, :datasets, :through => :datasetprotein

    has n, :peptidespectrummatch
end

class DatasetProtein
    include DataMapper::Resource
    property :id,               Serial
    
    belongs_to :protein
    belongs_to :dataset
end

class PeptideProtein
    include DataMapper::Resource
    property :id,               Serial
    property :sequence,         String      #For Fast Querying

    belongs_to :protein
    belongs_to :peptide
end

class ModificationProtein
    include DataMapper::Resource
    property :id,               Serial
    
    belongs_to :protein
    belongs_to :modification
end


class Peptidespectrummatch
    include DataMapper::Resource
    property :id,               Serial
    property :filename,         String
    property :scan,             String
    property :tabfile,          String
    property :sequence,         String

    belongs_to :peptide
    belongs_to :variant
    belongs_to :dataset
    belongs_to :protein

    has n, :modifications, :through => :modificationpeptidespectrummatch
end

class ModificationPeptidespectrummatch
    include DataMapper::Resource
    property :id,               Serial
    
    belongs_to :peptidespectrummatch
    belongs_to :modification
end


DataMapper.finalize
Peptide.auto_migrate! unless Peptide.storage_exists?
Dataset.auto_migrate! unless Dataset.storage_exists?
DatasetPeptide.auto_migrate! unless DatasetPeptide.storage_exists?
Protein.auto_migrate! unless Protein.storage_exists?
PeptideProtein.auto_migrate! unless PeptideProtein.storage_exists?
Peptidespectrummatch.auto_migrate! unless Peptidespectrummatch.storage_exists?
Modification.auto_migrate! unless Modification.storage_exists?
ModificationPeptide.auto_migrate! unless ModificationPeptide.storage_exists?
Variant.auto_migrate! unless Variant.storage_exists?
ModificationVariant.auto_migrate! unless ModificationVariant.storage_exists?
Protein.auto_migrate! unless Protein.storage_exists?
DatasetProtein.auto_migrate! unless DatasetProtein.storage_exists?
ModificationProtein.auto_migrate! unless ModificationProtein.storage_exists?
ModificationPeptidespectrummatch.auto_migrate! unless ModificationPeptidespectrummatch.storage_exists?
DatasetModification.auto_migrate! unless DatasetModification.storage_exists?
DataMapper.auto_upgrade!

