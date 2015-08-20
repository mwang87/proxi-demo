

def get_create_modification(modifications, peptide_db, variant_db, dataset_db, protein_db, psm_db)
	#Adding Modifications
    modifications.each { |modification|
        modification_split = modification.split("-", 2)


        mod_name = modification_split[1]
        mod_location = modification_split[0]
        modification_db = Modification.first_or_create(:name => mod_name)

        #Creating connection
        mod_variant_db = ModificationVariant.first_or_create(:modification => modification_db, 
        	:variant => variant_db, 
        	:location => mod_location)
        mod_peptide_db = ModificationPeptide.first_or_create(:modification => modification_db, 
        	:peptide => peptide_db)
     	mod_protein_db = ModificationProtein.first_or_create(:modification => modification_db, 
        	:protein => protein_db)
        mod_dataset_db = DatasetModification.first_or_create(:modification => modification_db, 
        	:dataset => dataset_db)
        mod_psm_db = ModificationPeptidespectrummatch.first_or_create(:modification => modification_db, 
        	:peptidespectrummatch => psm_db)
    }
end