get '/psm/:psmid' do
	@psm = Datasetvariantspectrummatch.first(:id => params[:psmid])

	haml :psm_page
end


get '/modification/:mod/psm/list' do
	page_number, @previous_page, @next_page = page_prev_next_utilties(params)

    mod_db = Modification.first(:id => params[:mod])

    @psms = Datasetvariantspectrummatch.all(:DatasetVariant => DatasetVariant.all(:variant => mod_db.variants), :offset => (page_number - 1) * PAGINATION_SIZE, :limit => PAGINATION_SIZE)

    haml :psms_all

end