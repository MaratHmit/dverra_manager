| import parallel from 'async/parallel'
| import './delivery-regions.tag'
| import './delivery-condition-param-modal.tag'
| import './delivery-condition-regions-modal.tag'
| import 'components/week-days-checkbox.tag'

delivery-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#settings/delivery') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ checkPermission("deliveries", "0010") }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? item.name || 'Добавление типа доставки' : item.name || 'Редактирование типа доставки' }

        ul.nav.nav-tabs.m-b-2
            li.active #[a(data-toggle='tab', href='#delivery-edit-delivery') Доставка]
            li(if='{ ~regions.indexOf(item.code) }') #[a(data-toggle='tab', href='#delivery-edit-terms-of-pricing') Условия формирования цен]
            li #[a(data-toggle='tab', href='#delivery-edit-setup-payments') Настройка оплат]
            li #[a(data-toggle='tab', href='#delivery-edit-product-groups') Группы товаров]
            li(if='{ ~regions.indexOf(item.code) }') #[a(data-toggle='tab', href='#delivery-edit-regions-geolocation') Регионы геолокации]

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .tab-content
                #delivery-edit-delivery.tab-pane.fade.in.active
                    .row
                        .col-md-3
                            .form-group(class='{ has-error: error.name }')
                                label.control-label Наименование
                                input.form-control(name='name', value='{ item.name }')
                                .help-block { error.name }
                        .col-md-3
                            .form-group(class='{ has-error: error.code }')
                                label.control-label Тип доставки
                                select.form-control(name='code', value='{ item.code }')
                                    option(each='{ deliveriesTypes }', value='{ code }',
                                    selected='{ code == item.code }', no-reorder) { name }
                                .help-block { error.code }
                        .col-md-3
                            .form-group(class='{ has-error: error.currency }')
                                label.control-label Валюта
                                select.form-control(name='currency', value='{ item.curr }')
                                    option(each='{ c, i in currencies }', value='{ c.name }',
                                    selected='{ c.name == item.curr }', no-reorder) { c.title }
                                .help-block { error.currency }
                        .col-md-3
                            .form-group
                                label.control-label Дни недели
                                br
                                week-days-checkbox(name='week', value='{ item.week }')
                    .row
                        .col-md-3
                            .form-group
                                label.control-label Время в пути
                                input.form-control(name='period', type='number', min='0', step='1',
                                value='{ item.period }')
                        .col-md-3
                            .form-group
                                label.control-label Базовая цена
                                input.form-control(name='price', type='number', min='0', step='0.01',
                                value='{ item.price }')
                        .col-md-3
                            .form-group
                                label.control-label Макс. вес
                                .input-group
                                    input.form-control(name='maxWeight', type='number', min='0', step='0.01',
                                    value='{ item.maxWeight }')
                                    span.input-group-addon гр
                        .col-md-3
                            .form-group
                                label.control-label Макс. объем
                                .input-group
                                    input.form-control(name='maxVolume', type='number', min='0', step='1',
                                    value='{ item.maxVolume }')
                                    span.input-group-addon см#[sup 3]

                    .row
                        .col-md-12
                            .form-group
                                label.control-label Примечание
                                textarea.form-control(name='note', rows='5', style='min-width: 100%; max-width: 100%;',
                                value='{ item.note }')

                    .row
                        .col-md-12
                            .form-group
                                .checkbox-inline
                                    label
                                        input(name='isActive', type='checkbox', checked='{ item.isActive }')
                                        | Активная
                                .checkbox-inline
                                    label
                                        input(name='onePosition', type='checkbox', checked='{ item.onePosition }')
                                        | Для одной позиции
                                .checkbox-inline
                                    label
                                        input(name='needAddress', type='checkbox', checked='{ item.needAddress }')
                                        | Требовать адрес

                #delivery-edit-terms-of-pricing.tab-pane.fade(if='{ ~regions.indexOf(item.code) }')
                    .row
                        .col-md-12
                            ul.nav.nav-tabs.m-b-2
                                li.active #[a(data-toggle='tab', href='#delivery-edit-terms-of-pricing-params') По параметрам]
                                li #[a(data-toggle='tab', href='#delivery-edit-terms-of-pricing-regions') По регионам]
                            .tab-content
                                #delivery-edit-terms-of-pricing-params.tab-pane.fade.in.active
                                    catalog-static(name='conditionsParams', rows='{ item.conditionsParams }',
                                    cols='{ conditionsParamsCols }', handlers='{ conditionsParamsHandlers }',
                                    add='{ conditionsParamsEdit }', dblclick='{ conditionsParamsEdit }')
                                        #{'yield'}(to='body')
                                            datatable-cell(name='formatPrice') { handlers.formatPrice(row) }
                                            datatable-cell(name='typeParam') { handlers.typeParam[row.typeParam] }
                                            datatable-cell(name='minValue') { row.minValue }
                                            datatable-cell(name='maxValue') { row.maxValue }
                                            datatable-cell(name='priority') { row.priority }

                                #delivery-edit-terms-of-pricing-regions.tab-pane.fade
                                    catalog-static(name='conditionsRegions', rows='{ item.conditionsRegions }',
                                    cols='{ conditionsRegionsCols }', handlers='{ conditionsRegionsHandlers }',
                                    add='{ conditionsRegionsEdit }', dblclick='{ conditionsRegionsEdit }')
                                        #{'yield'}(to='body')
                                            datatable-cell(name='name') { handlers.locationTextRender(row) }
                                            datatable-cell(name='price') { row.price }
                                            datatable-cell(name='period') { row.period } дн.
                                            datatable-cell(name='note') { row.note }

                #delivery-edit-setup-payments.tab-pane.fade
                    .row
                        .col-md-12
                            catalog(object='PaySystem', cols='{ paysystemsCols }', disable-col-select='true',
                            handlers='{ paysystemsHandlers }')
                                #{'yield'}(to='body')
                                    datatable-cell(name='name')
                                        i.fa.fa-fw(onclick='{ handlers.toggleCheckbox }',
                                        class='{handlers.checked.indexOf(row.id) > -1 ? "fa-check-square-o" : "fa-square-o" }')
                                        |  { row.name }

                #delivery-edit-product-groups.tab-pane.fade
                    .row
                        .col-md-12
                            catalog(object='Category', cols='{ productsGroupsCols }', remove='{ remove }', reload='true',
                            handlers='{ productsGroupsHandlers }')
                                #{'yield'}(to='body')
                                    datatable-cell(name='')
                                        i.fa.fa-fw(onclick='{ handlers.toggleCheckbox }',
                                        class='{ handlers.checked.indexOf(row.id) > -1 ? "fa-check-square-o" : "fa-square-o" }')
                                    datatable-cell(name='name') { row.name }

                #delivery-edit-regions-geolocation.tab-pane.fade(if='{ ~regions.indexOf(item.code) }')
                    catalog-static(name='geoLocationsRegions', rows='{ item.geoLocationsRegions }',
                    handlers='{ geoLocationsRegionsHandlers }', add='{ addGeoLocationsRegions }',
                    cols='{ geoLocationsRegionsCols }', dblclick='{ geoLocationsRegionsEdit }')
                        #{'yield'}(to='body')
                            datatable-cell(name='name') { handlers.locationTextRender(row) }


    script(type='text/babel').
        var self = this

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')
        self.item = {}
        self.citiesItems = {}

        function locationTextRender(item) {
            if (item.idCityTo) {
                let { idCountry, idRegion, name: city } = self.citiesItems[item.idCityTo]
                let { name: country } = self.countriesItems[idCountry]

                if (idRegion != 0) {
                    let { name: region } = self.regionsItems[idRegion]
                    return `${country}, ${region}, ${city}`
                } else
                    return `${country}, ${city}`
            }

            if (item.idRegionTo) {
                let { idCountry, name: region } = self.regionsItems[item.idRegionTo]
                let { name: country } = self.countriesItems[idCountry]
                return `${country}, ${region}`
            }

            if (item.idCountryTo) {
                return self.countriesItems[item.idCountryTo].name
            }
        }

        self.rules = {
            name: 'empty',
            code: 'empty',
            currency: 'empty',
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.regions = ['region', 'subregion']

        self.paysystemsCols = [
            {name: 'name', value: 'Наименование'}
        ]

        self.productsGroupsCols = [
            {name: '', value: '', width: '30px'},
            {name: 'name', value: 'Наименование'}
        ]

        self.conditionsParamsCols = [
            {name: 'formatprice', value: 'Формируемая цена'},
            {name: 'typeParam', value: 'Аргумент'},
            {name: 'minValue', value: 'Мин. знач.'},
            {name: 'maxValue', value: 'Макс. знач.'},
            {name: 'priority', value: 'Приоритет'},
        ]

        self.conditionsRegionsCols = [
            {name: 'name', value: 'Страна/Регион/Город'},
            {name: 'price', value: 'Цена'},
            {name: 'period', value: 'Срок'},
            {name: 'note', value: 'Адрес склада/примечание'}
        ]

        self.conditionsRegionsHandlers = {
            locationTextRender
        }

        self.geoLocationsRegionsCols = [
            {name: 'name', value: 'Страна/Регион/Город'}
        ]

        self.conditionsParamsHandlers = {
            typeParam: {
                sum: 'Сумма',
                weight: 'Вес',
                volume: 'Объем',
            },
            formatPrice(row) {
                let result = ''
                let { operation, typePrice, price } = row
                price = price || 0

                if (typePrice === 'a') {
                    switch (operation) {
                        case '=':
                            result = `${price}`
                            break
                        case '+':
                            result = `+${price} к базовой сумме доставки`
                            break
                        case '-':
                            result = `-${price} от базовой цены доставки`
                            break
                    }
                }

                if (typePrice === 's') {
                    switch (operation) {
                        case '=':
                            result = `${price}% от суммы заказа`
                            break
                        case '+':
                            result = `+${price}% суммы заказа к базовой цене доставки`
                            break
                        case '-':
                            result = `-${price}% суммы заказа от базовой цены доставки`
                            break
                    }
                }

                if (typePrice === 'd') {
                    switch (operation) {
                        case '=':
                            result = `${price || 0}% от базовой цены доставки`
                            break
                        case '+':
                            result = `${100 + price}% базовой цены доставки`
                            break
                        case '-':
                            result = `${100 - price}% базовой цены доставки`
                            break
                    }
                }

                return result
            }
        }

        self.conditionsParamsEdit = e => {
            let item

            if (e && e.item)
                item = e.item.row

            modals.create('delivery-condition-param-modal', {
                type: 'modal-primary',
                item,
                formatPrice: self.conditionsParamsHandlers.formatPrice,
                submit() {
                    let _this = this
                    if (!item) {
                        self.item.conditionsParams.push(_this.item)
                    }

                    self.update()
                    _this.modalHide()
                }
            })
        }

        self.conditionsRegionsEdit = e => {
            let item

            if (e && e.item)
                item = e.item.row

            modals.create('delivery-condition-regions-modal', {
                type: 'modal-primary',
                item,
                submit() {
                    if (this.tags.idCityTo.value) {
                        self.citiesItems[this.tags.idCityTo.value] = {}
                        self.citiesItems[this.tags.idCityTo.value].name = this.tags.idCityTo.filterValue

                        if (this.tags.idRegionTo.value)
                            self.citiesItems[this.tags.idCityTo.value].idRegion = this.tags.idRegionTo.value
                        else
                            self.citiesItems[this.tags.idCityTo.value].idRegion = 0

                        if (this.tags.idCountryTo.value)
                            self.citiesItems[this.tags.idCityTo.value].idCountry = this.tags.idCountryTo.value
                        else
                            self.citiesItems[this.tags.idCityTo.value].idCountry = 0
                    }


                    let _this = this
                    if (!item) {
                        self.item.conditionsRegions.push(_this.item)
                    }

                    self.update()
                    _this.modalHide()
                }
            })
        }

        self.geoLocationsRegionsHandlers = {
            locationTextRender
        }

        self.paysystemsHandlers = {
            checked: [],
            toggleCheckbox(e) {
                var idx = this.handlers.checked.indexOf(this.row.id)

                if (idx > -1)
                    this.handlers.checked.splice(idx, 1)
                else
                    this.handlers.checked.push(this.row.id)

                self.update()
            }
        }

        self.productsGroupsHandlers = {
            checked: [],
            toggleCheckbox(e) {
                var idx = self.productsGroupsHandlers.checked.indexOf(this.row.id)

                if (idx > -1)
                    self.productsGroupsHandlers.checked.splice(idx, 1)
                else
                    self.productsGroupsHandlers.checked.push(this.row.id)

                self.update()
            }
        }

        self.addGeoLocationsRegions = e => {
            modals.create('delivery-regions', {
                type: 'modal-primary',
                submit() {
                    var item = {
                        idCountryTo: this.tags.idCountryTo.value,
                        idRegionTo: this.tags.idRegionTo.value,
                        idCityTo: this.tags.idCityTo.value,
                    }

                    if (this.tags.idCityTo.value) {
                        self.citiesItems[this.tags.idCityTo.value] = {}
                        self.citiesItems[this.tags.idCityTo.value].name = this.tags.idCityTo.filterValue

                        if (this.tags.idRegionTo.value)
                            self.citiesItems[this.tags.idCityTo.value].idRegion = this.tags.idRegionTo.value
                        else
                            self.citiesItems[this.tags.idCityTo.value].idRegion = 0

                        if (this.tags.idCountryTo.value)
                            self.citiesItems[this.tags.idCityTo.value].idCountry = this.tags.idCountryTo.value
                        else
                            self.citiesItems[this.tags.idCityTo.value].idCountry = 0
                    }


                    self.item.geoLocationsRegions = self.item.geoLocationsRegions || []
                    self.item.geoLocationsRegions.push(item)
                    this.modalHide()
                    self.update()
                }
            })
        }

        self.geoLocationsRegionsEdit = e => {
            modals.create('delivery-regions', {
                type: 'modal-primary',
                item: e.item.row,
                submit() {
                    if (this.tags.idCityTo.value) {
                        self.citiesItems[this.tags.idCityTo.value] = {}
                        self.citiesItems[this.tags.idCityTo.value].name = this.tags.idCityTo.filterValue

                        if (this.tags.idRegionTo.value)
                            self.citiesItems[this.tags.idCityTo.value].idRegion = this.tags.idRegionTo.value
                        else
                            self.citiesItems[this.tags.idCityTo.value].idRegion = 0

                        if (this.tags.idCountryTo.value)
                            self.citiesItems[this.tags.idCityTo.value].idCountry = this.tags.idCountryTo.value
                        else
                            self.citiesItems[this.tags.idCityTo.value].idCountry = 0
                    }

                    this.parent.item.idCountryTo = this.tags.idCountryTo.value
                    this.parent.item.idRegionTo = this.tags.idRegionTo.value
                    this.parent.item.idCityTo = this.tags.idCityTo.value
                    this.modalHide()
                    self.update()
                }
            })
        }

        self.submit = () => {
            self.error = self.validation.validate(self.item, self.rules)

            if (!self.error) {
                self.loader = true

                API.request({
                    object: 'Delivery',
                    method: 'Save',
                    data: self.item,
                    success(response) {
                        self.item = response
                        observable.trigger('delivery-reload')
                        popups.create({title: 'Успех!', text: 'Тип доставки сохранен!', style: 'popup-success'})
                    },
                    complete(){
                        self.loader = false
                        self.update()
                    }
                })
            }
        }

        self.reload = () => {
            observable.trigger('delivery-edit', self.item.id)
        }

        observable.on('delivery-edit', id => {
            var params = {id: id}
            self.error = false
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()

            parallel([
                callback => {
                    API.request({
                        object: 'Delivery',
                        method: 'Info',
                        data: params,
                        success(response) {
                            self.item = response
                            self.deliveriesTypes = response.deliveriesTypes
                            self.currencies = response.currencies
                            self.paysystemsHandlers.checked = response.idsPaySystems || []
                            self.productsGroupsHandlers.checked = response.idsGroups || []
                            callback(null, 'Deliveries')
                        },
                        error(response) {
                            callback('error', null)
                        }
                    })
                }], (err, res) => {
                    if (self.item.geoLocationsRegions &&
                        self.item.geoLocationsRegions instanceof Array) {
                        var geoLocationsRegionsIds = self.item.geoLocationsRegions.map(item => item.idCityTo).filter(item => item)
                        var conditionsRegionsIds = self.item.conditionsRegions.map(item => item.idCityTo).filter(item => item)
                        API.request({
                            object: 'GeoCity',
                            method: 'Fetch',
                            data: {ids: [...geoLocationsRegionsIds, ...conditionsRegionsIds]},
                            success(response) {
                                self.citiesItems = {}

                                response.items.forEach(item => {
                                    self.citiesItems[item.id] = {
                                        idCountry: item.idCountry,
                                        idRegion: item.idRegion,
                                        name: item.name
                                    }
                                })

                                self.loader = false
                                self.update()
                            }
                        })
                    } else {
                        self.loader = false
                        self.update()
                    }
                }
            )

        })

        observable.on('delivery-new', () => {
            self.error = false
            self.isNew = true
            self.item = {}
            parallel([
                callback => {
                    API.request({
                        object: 'DeliveryType',
                        method: 'Fetch',
                        success(response) {
                            self.deliveriesTypes = response.items
                            callback(null, 'Deliveries')
                        },
                        error(response) {
                            callback('error', null)
                        }
                    })
                },
                callback => {
                    API.request({
                        object: 'Currency',
                        method: 'Fetch',
                        success(response) {
                            self.currencies = response.items
                            callback(null, 'Deliveries')
                        },
                        error(response) {
                            callback('error', null)
                        }
                    })
                }
            ], (err, res) => {
                if (self.item.geoLocationsRegions &&
                    self.item.geoLocationsRegions instanceof Array) {
                    var geoLocationsRegionsIds = self.item.geoLocationsRegions.map(item => item.idCityTo).filter(item => item)
                    var conditionsRegionsIds = self.item.conditionsRegions.map(item => item.idCityTo).filter(item => item)
                    API.request({
                        object: 'GeoCity',
                        method: 'Fetch',
                        data: {ids: [...geoLocationsRegionsIds, ...conditionsRegionsIds]},
                        success(response) {
                            self.citiesItems = {}

                            response.items.forEach(item => {
                                self.citiesItems[item.id] = {
                                    idCountry: item.idCountry,
                                    idRegion: item.idRegion,
                                    name: item.name
                                }
                            })

                            self.loader = false
                            self.update()
                        }
                    })
                } else {
                    self.loader = false
                    self.update()
                }
            })
        })

        self.on('mount', () => {
            API.request({
                object: 'GeoCountry',
                method: 'Fetch',
                success(response) {
                    self.countriesItems = {}
                    response.items.forEach(item => {
                        self.countriesItems[item.id] = {code: item.code, name: item.name}
                    })
                    self.update()
                }
            })
            API.request({
                object: 'GeoRegion',
                method: 'Fetch',
                success(response) {
                    self.regionsItems = {}
                    response.items.forEach(item => {
                        self.regionsItems[item.id] = {code: item.code, idCountry: item.idCountry, name: item.name}
                    })
                    self.update()
                }
            })
            riot.route.exec()
        })

