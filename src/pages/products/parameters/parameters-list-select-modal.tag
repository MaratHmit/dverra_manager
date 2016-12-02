parameters-list-select-modal
	bs-modal
		#{'yield'}(to="title")
			.h4.modal-title Параметры
		#{'yield'}(to="body")
			catalog(object='Feature', cols='{ parent.cols }', search='true', add='{ parent.add }', remove='true',
			handlers='{ parent.handlers }', reload='true', filters='{ parent.opts.filters }')
				#{'yield'}(to='body')
					datatable-cell(name='id') { row.id }
					datatable-cell(name='name') { row.name }
					datatable-cell(name='type') { handlers.featureName(row.type) }
		#{'yield'}(to='footer')
			button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
			button(onclick='{ parent.opts.submit.bind(this) }', type='button', class='btn btn-primary btn-embossed') Выбрать

	script(type='text/babel').
		var self = this

		var getFeaturesTypes = () => {
			API.request({
				object: 'FeatureType',
				method: 'Fetch',
				data: {},
				success(response) {
					self.featuresTypes = response.items
					self.update()
				}
			})
		}

		var featureName = type => {
			for (var i = 0; i < self.featuresTypes.length; i++) {
				if (self.featuresTypes[i].code === type)
					return self.featuresTypes[i].name
			}
		}

		self.add = () => {
			modals.create('parameter-new-modal', {
				type: 'modal-primary',
				submit() {
					var _this = this
					var params = {name: _this.name.value}

					API.request({
						object: 'Feature',
						method: 'Save',
						data: params,
						success(response) {
							_this.modalHide()
							if (response.id)
								riot.route(`products/parameters/${response.id}`)
						}
					})
				}
			})
		}

		self.cols = [
			{name: 'id', value: '#'},
			{name: 'name', value: 'Наименование'},
			{name: 'type', value: 'Тип параметра'},
		]

		self.handlers = {
			featureName: featureName
		}

		getFeaturesTypes()