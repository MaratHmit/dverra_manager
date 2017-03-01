geo-zones-region-edit-modal
    bs-modal
        #{'yield'}(to="title")
            .h4.modal-title { 'Регион/город' }
        #{'yield'}(to="body")
            form(onchange='{ change }', onkeyup='{ change }')
                .row
                    .col-md-12
                        .form-group(class='{ has-error: error.region }')
                            label.control-label Регион
                            select.form-control(name='idRegion', value='{ item.idRegion }', onchange='{ regionChange }')
                                option(each='{ regions }', value='{ id }',
                                    selected='{ id == item.idRegion }', no-reorder) { name }
                .row
                    .col-md-12
                        .form-group(class='{ has-error: error.city }')
                            label.control-label Город
                            select.form-control(name='idCity', value='{ item.idCity }', onchange='{ cityChange }')
                                option(each='{ cities }', value='{ id }',
                                    selected='{ id == item.idCity }', no-reorder) { name }
                .row
                    .col-md-12
                        .form-group
                            label.control-label Округ
                            input.form-control(name='area', value='{ item.area }')

        #{'yield'}(to='footer')
            button(onclick='{ modalHide }', type='button', class='btn btn-default btn-embossed') Закрыть
            button(onclick='{ parent.opts.submit }', type='button', class='btn btn-primary btn-embossed') Сохранить

        script(type='text/babel').
            var self = this

            self.on('mount', () => {
                let modal = self.tags['bs-modal']

                modal.error = false
                modal.isNew = opts.isNew || false
                modal.item = opts.item || {}
                modal.mixin('validation')
                modal.mixin('change')

                modal.rules = {
                    region: 'empty',
                    city: 'empty',
                }

                modal.afterChange = e => {
                    let name = e.target.name
                    delete modal.error[name]
                    modal.error = {...modal.error, ...modal.validation.validate(modal.item, modal.rules, name)}
                }

                modal.getCities = (idRegion) => {
                    API.request({
                        object: 'AtdCity',
                        method: 'Fetch',
                        data: {filters: {field: 'idRegion', value: idRegion }},
                        success(response) {
                            modal.cities = response.items
                            if (modal.cities.length) {
                                modal.item.idCity = modal.cities[0].id
                                modal.item.city = modal.cities[0].name
                            }
                            self.update()
                        }
                    })
                }

                modal.regionChange = (e) => {
                    modal.item.idRegion = e.target.value
                    modal.regions.forEach((region) => {
                        if (region.id == modal.item.idRegion) {
                            modal.item.region = region.name
                            return true
                        }
                    })
                    modal.getCities(modal.item.idRegion)
                }

                modal.cityChange = (e) => {
                    modal.item.idCity = e.target.value
                    modal.cities.forEach((city) => {
                        if (city.id == modal.item.idCity) {
                            modal.item.city = city.name
                            return true
                        }
                    })
                }

                API.request({
                    object: 'AtdRegion',
                    method: 'Fetch',
                    success(response) {
                        modal.regions = response.items
                        if (modal.regions.length && !modal.item.idRegion) {
                            modal.item.idRegion = modal.regions[0].id
                            modal.item.region= modal.regions[0].name
                        }
                        modal.getCities(modal.item.idRegion)
                    }
                })

            })
