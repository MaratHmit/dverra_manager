| import 'components/datetime-picker.tag'
| import 'pages/settings/delivery/delivery-list-modal.tag'
| import 'pages/payments/payments-list-modal.tag'
| import 'pages/products/products/products-list-select-modal.tag'
| import 'pages/products/products/offers-list-select-modal.tag'
| import 'pages/products/shop-services/shop-services-list-select-modal.tag'
| import 'pages/schedule/schedule-modal.tag'
| import 'components/loader.tag'
| import 'pages/persons/person-new-modal.tag'
| import 'inputmask'

order-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#orders') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ isNew ? checkPermission("orders", "0100") : checkPermission("orders", "0010") }',
            onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? 'Новый заказ' : 'Редактирование заказа № ' + item.num }
        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-1
                    .form-group
                        label.control-label №
                        input.form-control(name='num', value='{ item.num }')
                .col-md-2
                    .form-group
                        label.control-label Дата заказа
                        datetime-picker.form-control(name='date',
                        format='DD.MM.YYYY HH:mm', value='{ item.dateDisplay }', icon='glyphicon glyphicon-calendar')
                .col-md-3
                    .form-group(class='{ has-error: (error.idUser) }')
                        label.control-label Заказчик
                        .input-group
                            a.input-group-addon(if='{ item.idUser }',
                            href='{ "#persons/" + item.idUser }', target='_blank')
                                i.fa.fa-eye
                            input.form-control(name='idUser',
                                value='{ item.idUser ? item.idUser + " - " + item.customer : "" }', readonly)
                            span.input-group-addon(onclick='{ changeCustomer }')
                                i.fa.fa-list
                            span.input-group-addon(onclick='{ newCustomer }')
                                i.fa.fa-plus
                        .help-block { error.idUser }
            .row
                .col-md-12
                    .well.well-sm
                        catalog-static(name='items', rows='{ item.items }', cols='{ itemsCols }',
                        handlers='{ itemsHandlers }')
                            #{'yield'}(to='toolbar')
                                .form-group
                                    button.btn.btn-primary(type='button', onclick='{ opts.handlers.addProducts }')
                                        i.fa.fa-plus
                                        |  Добавить товар
                                    button.btn.btn-primary(type='button', onclick='{ opts.handlers.addServices }')
                                        i.fa.fa-plus
                                        |  Добавить услугу
                            #{'yield'}(to='body')
                                datatable-cell(name='name') { row.name }
                                datatable-cell(name='count')
                                    input(value='{ row.count }', type='number', step='1', min='1',
                                    onchange='{ handlers.numberChange }')
                                datatable-cell(name='price')
                                    input(value='{ row.price }', type='number', step='1', min='0',
                                    onchange='{ handlers.numberChange }')
                                datatable-cell(name='discount')
                                    input(value='{ row.discount }', type='number', step='1', min='0',
                                    onchange='{ handlers.numberChange }')
                                datatable-cell(name='sum') { (row.count * row.price - row.discount).toLocaleString() } ₽
                        .alert.alert-danger(if='{ error.items }')
                            | { error.items }

            .row
                .col-md-12
                    .panel.panel-default
                        .panel-heading
                            h4.panel-title Суммы
                        .panel-body
                            .col-md-3
                                .form-group
                                    label.control-label Товаров
                                    input.form-control(value='{ sumProducts.toLocaleString() } ₽', readonly)
                            .col-md-3
                                .form-group
                                    label.control-label Услуг
                                    input.form-control(value='{ sumServices.toLocaleString() } ₽', readonly)
                            .col-md-3
                                .form-group
                                    label.control-label Скидка
                                    input.form-control(name='discount', type='number',
                                        value='{ item.discount / 1 }', min='0', step='1')
                            .col-md-3
                                .form-group.has-success
                                    label.control-label Итого
                                    input.form-control(value='{ total.toLocaleString() } ₽', readonly)
            .row
                .col-md-12
                    .panel.panel-default
                        .panel-heading
                            h4.panel-title Адрес работ
                        .panel-body
                            .col-md-2
                                .form-group
                                    label.control-label Регион
                                    select.form-control(name='idAddressRegion', value='{ item.idAddressRegion }', onchange='{ regionChange }')
                                        option(each='{ regions }', value='{ id }',
                                        selected='{ id == item.idAddressRegion }', no-reorder) { name }
                            .col-md-2
                                .form-group
                                    label.control-label Город
                                    select.form-control(name='idAddressCity', value='{ item.idAddressCity }', onchange='{ cityChange }')
                                        option(each='{ cities }', value='{ id }',
                                        selected='{ id == item.idAddressCity }', no-reorder) { name }
                            .col-md-2
                                .form-group
                                    label.control-label { item.addressStreetType ?  item.addressStreetType : 'Улица' }
                                    select-streets(name='addressStreet', values='{ streets }', value='{ item.addressStreet }',
                                    oninput='{ handlers.getStreets }', set='{ setStreet }', onchange='{ geoFix }' )
                            .col-md-1
                                .form-group
                                    label.control-label Дом/строение
                                    input.form-control(name='addressBuilding', value='{ item.addressBuilding }',
                                    onchange='{ buildingChange }', disabled='{ !item.addressStreet }')
                            .col-md-1
                                .form-group
                                    label.control-label Квартира
                                    input.form-control(name='addressApartment',
                                    value='{ item.addressApartment }', disabled='{ !item.addressBuilding }')
                            .col-md-4(if='{ item.idAddressCity == 1 }')
                                .form-group
                                    label.control-label Округ
                                    input.form-control(name='addressArea', value='{ item.addressArea }', disabled)
            .row
                .col-md-2
                    .form-group
                        label.control-label Район работ
                        select.form-control(name='idGeoZone', value='{ item.idGeoZone }')
                            option(each='{ zones }', value='{ id }',
                            selected='{ id == item.idGeoZone }', no-reorder) { name }

                .col-md-2
                    .form-group
                        label.control-label Дата и время выполнения замера
                        .input-group
                            input.form-control(name='serviceDate',
                            value='{ item.serviceDate }', readonly)
                            span.input-group-addon(onclick='{ getServiceDate }')
                                i.fa.fa-calendar
                .col-md-8
                    .form-group
                        label.control-label Примечание по заказу
                        input.form-control(name='note', value='{ item.note }')
            .row
                .col-md-12(id="map", style="width: 600px; height: 600px")


    script(type='text/babel').
        var self = this,
            route = riot.route.create()


        self.isNew = false
        self.item = {}
        self.regions = []
        self.cities = []
        self.streets = []
        self.loader = false
        self.sumProducts = 0
        self.sumServices = 0
        self.total = 0

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')

        self.rules = () => {
            let rules = {
                items: {
                    required: true,
                    rules: [{
                        type: 'minLength[1]',
                        prompt: 'В списке должно быть не менее одного элемента'
                    }]
                },
            }

            if (self.item && self.item.idUser)
                return { ...rules }
            else
                return { ...rules, idUser: 'empty' }
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules(), name)}
        }

        self.itemsCols = [
            {name: 'name', value: 'Наименование'},
            {name: 'count', value: 'Кол-во'},
            {name: 'price', value: 'Цена'},
            {name: 'discount', value: 'Скидка'},
            {name: 'amount', value: 'Стоимость'},
        ]

        self.itemsHandlers = {
            numberChange(e) {
                this.row[this.opts.name] = e.target.value
            },
            addProducts() {
                modals.create('products-list-select-modal', {
                    type: 'modal-primary',
                    size: 'modal-lg',
                    submit() {
                        let _this = this
                        let items = _this.tags.catalog.tags.datatable.getSelectedRows()
                        self.item.items = self.item.items || []
                        if (items.length > 0) {
                            let idsExist = self.item.items.map(item => item.id)
                            let ids = items.map(item => item.id)
                            let value = ids.join(",")
                            let params = { filters: { field: 'idProduct', sign: 'IN', value: value } }
                            console.log(params)
                            API.request({
                                object: 'Offer',
                                method: 'Fetch',
                                data: params,
                                success(response) {
                                    console.log(response)
                                }
                            })

                            /*
                            items.forEach(item => {
                                if (ids.indexOf(item.id) === -1)
                                    self.item.items.push({...item, count: 1, discount: 0, id: null, idOffer: item.id})
                            })
                            self.update()
                            _this.modalHide()
                            let event = document.createEvent('Event')
                            event.initEvent('change', true, true)
                            self.tags.items.root.dispatchEvent(event)
                            */
                        }
                    }
                })
            },
            addServices() {
                modals.create('shop-services-list-select-modal', {
                    type: 'modal-primary',
                    size: 'modal-lg',
                    submit() {
                        let _this = this
                        let items = _this.tags.catalog.tags.datatable.getSelectedRows()
                        self.item.items = self.item.items || []
                        if (items.length > 0) {
                            let ids = self.item.items.map(item => item.id)
                            items.forEach(item => {
                            if (ids.indexOf(item.id) === -1)
                                self.item.items.push({...item, count: 1, discount: 0, id: null, idService: item.id})
                           })
                            self.update()
                            _this.modalHide()
                            let event = document.createEvent('Event')
                            event.initEvent('change', true, true)
                            self.tags.items.root.dispatchEvent(event)
                        }
                    }
                })
            }
        }

        self.statuses = []

        self.changeCustomer = () => {
            modals.create('persons-list-select-modal',{
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()
                    if (items.length > 0) {
                        self.item.idUser = items[0].id
                        self.item.customer = items[0].name
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }

        self.newCustomer = () => {
            modals.create('person-new-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                    var params = { name: _this.name.value, phone: _this.phone.value, email: _this.email.value }
                    API.request({
                        object: 'User',
                        method: 'Save',
                        data: params,
                        success(response) {
                            popups.create({title: 'Успех!', text: 'Контакт добавлен!', style: 'popup-success'})
                            _this.modalHide()
                            self.item.idUser = response.id
                            self.item.customer = response.name
                            self.update()
                            if (response.isExist) {
                                modals.create('bs-alert', {
                                    type: 'modal-danger',
                                    title: 'Предупреждение',
                                    text: 'Внимание! Контакт с указанным новером уже существует!\nБудет взят контакт из справочника!',
                                    size: 'modal-sm',
                                    buttons: [
                                        {action: 'ok', title: 'Я понял', style: 'btn-default'},
                                    ],
                                    callback() {
                                        this.modalHide()
                                        _this.modalHide()
                                    }
                                })
                            }
                        }
                    })
                }
            })
            $('.phone-mask').mask("+7 (999) 999-99-99",{ "placeholder": " " })
        }


        self.submit = e => {
            var params = self.item
            self.error = self.validation.validate(self.item, self.rules())

            if (!self.error) {
                API.request({
                    object: 'Order',
                    method: 'Save',
                    data: params,
                    success(response) {
                        self.item = response
                        self.isNew = false
                        self.update()
                        if (self.isNew)
                            riot.route(`/orders/${self.item.id}`)
                        popups.create({title: 'Успех!', text: 'Заказ сохранен!', style: 'popup-success'})
                        observable.trigger('orders-reload')
                    }
                })
            }
        }

        self.reload = e => {
            observable.trigger('orders-edit', self.item.id)
        }

        self.on('update', () => {
            if (self.item && self.item.items) {
                let products = self.item.items.filter(item => {
                    return item.idOffer > 0
                })
                let services = self.item.items.filter(item => {
                    return item.idService > 0
                })
                self.sumProducts = products.map(i => i.count * i.price - i.discount).reduce((sum, current) => sum + current, 0)
                self.sumServices = services.map(i => i.count * i.price - i.discount).reduce((sum, current) => sum + current, 0)
                let sum = self.sumProducts + self.sumServices
                if (parseFloat(sum) > 0)
                    self.total = parseFloat(sum || 0) - parseFloat(self.item.discount || 0)
                else
                    self.total = 0
            }
        })

        self.getRegions = () => {
            API.request({
                object: 'AtdRegion',
                method: 'Fetch',
                success(response) {
                    self.regions = response.items
                    if (self.regions.length) {
                        self.item.idAddressRegion = !!self.item.idAddressRegion ? self.item.idAddressRegion : self.regions[0].id
                        self.getCities(self.item.idAddressRegion)
                    }
                    self.update()
                }
            })
        }

        self.getZones = () => {
            API.request({
                object: 'GeoZone',
                method: 'Fetch',
                success(response) {
                    self.zones = response.items
                    self.update()
                }
            })
        }

        self.getCities = (idRegion) => {
            API.request({
                object: 'AtdCity',
                method: 'Fetch',
                data: {filters: {field: 'idRegion', value: idRegion }},
                success(response) {
                    self.cities = response.items
                    if (self.cities.length) {
                        self.item.idAddressCity = !!self.item.idAddressCity ? self.item.idAddressCity : self.cities[0].id
                        self.getStreets(self.item.idAddressCity)
                    }
                    self.update()
                }
            })
        }

        self.getStreets = (idCity) => {

            let zipCode = null
            self.cities.forEach((city) => {
                if (city.id == idCity) {
                    zipCode = city.zipCode
                    return true
                }
            })

            API.request({
                object: 'AtdStreet',
                method: 'Fetch',
                data: { zipCode: zipCode , value: self.item.addressStreet },
                success(response) {
                    self.streets = response.items
                    self.update()
                }
            })
        }

        self.setStreet = (name, type) => {
            self.item.addressStreet = name
            self.item.addressStreetType = type
            self.update()
        }

        self.buildingChange = (e) => {
            self.item.addressBuilding = e.target.value
            self.geoFix()
        }

        self.geoFix = () => {

            let region = 'Москва'
            let city = 'Москва'

            self.regions.forEach((item) => {
                if (item.id == self.item.idAddressRegion) {
                    region = item.name
                    return true
                }
            })

            self.cities.forEach((item) => {
                if (item.id == self.item.idAddressCity) {
                    city = item.name
                    return true
                }
            })

            let address = region + ',+' + city + ',+' + self.item.addressStreet + ',+' +
                self.item.addressStreetType + ',+дом+' + self.item.addressBuilding
            console.log(address)

            API.request({
                object: 'AtdStreet',
                method: 'Info',
                data: { value: address, idCity: self.item.idAddressCity },
                success(response) {
                   self.item.addressArea = response.addressArea
                   self.item.geoLongitude = response.geoLongitude
                   self.item.geoLatitude = response.geoLatitude
                   if (!!response.idGeoZone) {
                       self.item.idGeoZone = response.idGeoZone
                       self.setCoordinate()
                   } else {
                       modals.create('bs-alert', {
                           type: 'modal-danger',
                           title: 'Предупреждение',
                           text: 'Внимание! Не удаётся определить район замера автоматически!\nУстановите район замера в ручную!',
                           size: 'modal-sm',
                           buttons: [
                               {action: 'ok', title: 'Я понял', style: 'btn-default'},
                           ],
                           callback() {
                               this.modalHide()
                           }
                       })
                   }

                   self.update()
                }
            })
        }

        self.handlers = {
            getStreets(e) {
                self.item.addressStreet = e.target.value
                self.getStreets(self.item.idAddressCity)
            }
        }

        self.regionChange = (e) => {
            self.cities = []
            self.streets = []
            self.item.addressArea = null
            self.item.geoLongitude = null
            self.item.geoLatitude = null
            self.item.addressStreet = null

            self.update()
            self.getCities(e.target.value)
        }

        self.cityChange = (e) => {

            self.streets = []
            self.item.addressArea = null
            self.item.geoLongitude = null
            self.item.geoLatitude = null
            self.item.addressStreet = null
            self.item.idAddressCity = e.target.value

            self.update()
            self.getStreets(self.item.idAddressCity)
        }

        
        self.getServiceDate = () => {
            if (!self.item.idAddressCity || !self.item.addressStreet) {
                modals.create('bs-alert', {
                   type: 'modal-danger',
                   title: 'Ошибка',
                   text: 'Внимание! Не задан адрес замера!\nДля выбора даты замера укажите адрес замера!',
                   size: 'modal-sm',
                   buttons: [
                       {action: 'ok', title: 'Я понял', style: 'btn-default'},
                   ],
                   callback() {
                      this.modalHide()
                   }
                })
                return
            }

            if (!self.item.idGeoZone) {
                modals.create('bs-alert', {
                    type: 'modal-danger',
                    title: 'Ошибка',
                    text: 'Внимание! Не задан район замера!\nДля выбора даты замера укажите район замера!',
                    size: 'modal-sm',
                    buttons: [
                        {action: 'ok', title: 'Я понял', style: 'btn-default'},
                    ],
                    callback() {
                        this.modalHide()
                    }
                })
                return
            }

            modals.create('schedule-modal',{
                serviceDate: self.item.serviceDate,
                idSchedule: 1,
                idGeoZone: self.item.idGeoZone,
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    let event = this.selectedEvent
                    self.item.serviceDate = event.date + ' ' + event.time
                    this.modalHide()
                    self.update()
               }
            })
        }

        observable.on('order-new', () => {
            self.error = false
            self.isNew = true
            self.item = {sumDelivery: 0, discount: 0, idStatus: 2}
            self.item.dateDisplay = (new Date()).toLocaleString()
            self.getRegions()
            self.getZones()

            API.request({
                object: 'Order',
                method: 'Info',
                success(response) {
                    self.item.num = response.newNum
                    self.setCoordinate()
                    if (mapYandexOrder)
                        mapYandexOrder.setCenter([55.76, 37.64], 10);
                    self.update()
                }
            })
        })

        observable.on('orders-edit', id => {
            var params = {id}
            self.error = false
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()

            API.request({
                object: 'Order',
                method: 'Info',
                data: params,
                success(response) {
                    self.item = response
                    self.setCoordinate()
                    self.loader = false
                    self.update()
                    self.getRegions()
                    self.getZones()

                }
            })
        })

        self.setCoordinate = () => {
            if (mapYandexOrder) {
                if (mapYandexOrder.geoObjects)
                mapYandexOrder.geoObjects.removeAll()
                if (self.item.geoLatitude) {
                    let placemark = new ymaps.Placemark([self.item.geoLatitude, self.item.geoLongitude], {
                        hintContent: self.item.addressStreetType + " " + self.item.addressStreet +
                            ', дом ' + self.item.addressBuilding + ", " + self.item.addressApartment,
                    });
                    mapYandexOrder.geoObjects.add(placemark);
                    mapYandexOrder.setCenter([self.item.geoLatitude, self.item.geoLongitude], 12);
                }
            }
        }


        self.on('mount', () => {
            riot.route.exec()
        })

        ymaps.ready(initMapOrder);
        var mapYandexOrder;

        function initMapOrder(){
            mapYandexOrder = new ymaps.Map("map", {
                center: [55.76, 37.64],
                zoom: 10
            });
            self.setCoordinate()
        }