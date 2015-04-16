get '/psm/:psmid' do
	@psm = Datasetpeptidespectrummatch.first(:id => params[:psmid])

	haml :psm_page
end