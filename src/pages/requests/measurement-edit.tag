| import 'components/loader.tag'
| import 'pages/schedule/schedule-modal.tag'
| import 'pages/persons/person-new-modal.tag'
| import 'inputmask'
| import 'components/select-streets.tag'

measurement-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#requests/measurements') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(if='{ !isNew }', onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? 'Новый замер' : 'Редактирование замера № ' + item.num }

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .row
                .col-md-1
                    .form-group
                        label.control-label №
                        input.form-control(name='num', value='{ item.num }')
                .col-md-2
                    .form-group
                        label.control-label Дата формирования
                        input.form-control(name='date',
                            value='{ item.dateDisplay }', readonly)
                .col-md-3
                    .form-group(class='{ has-error: (error.idUser) }')
                        label.control-label Контакт
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
                .col-md-3
                    .form-group
                        label.control-label Телефон
                        input.form-control(name='phone', value='{ item.phone }', readonly)
            .row
                .col-md-12
                    .panel.panel-default
                        .panel-heading
                            h4.panel-title Адрес замера
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
                                        oninput='{ handlers.getStreets }', set='{ setStreet }' )
                            .col-md-1
                                .form-group
                                    label.control-label Дом/строение
                                    input.form-control(name='addressBuilding', value='{ item.addressBuilding }',
                                        onchange='{ geoFix }', disabled='{ !item.addressStreet }')
                            .col-md-1
                                .form-group
                                    label.control-label Квартира
                                    input.form-control(name='addressApartment',
                                        value='{ item.addressApartment }', disabled='{ !item.addressBuilding }')
                            .col-md-4(if='{ item.idAddressCity == 1 }')
                                .form-group
                                    label.control-label Округ
                                    input.form-control(name='dependent', value='{ item.dependent }', disabled)
            .row
                .col-md-2
                    .form-group
                        label.control-label Район замера
                        select.form-control(name='idGeoZone', value='{ item.idGeoZone }')
                            option(each='{ zones }', value='{ id }',
                            selected='{ id == item.idGeoZone }', no-reorder) { name }

                .col-md-2
                    .form-group
                        label.control-label Дата и время выполнения замера
                        .input-group
                            input.form-control(name='measurementDate',
                                value='{ item.measurementDate }', readonly)
                            span.input-group-addon(onclick='{ getMeasurementDate }')
                                i.fa.fa-calendar
                .col-md-8
                    .form-group
                        label.control-label Примечание по замеру
                        input.form-control(name='note', value='{ item.note }')
            .row
                .col-md-12(id="map", style="width: 600px; height: 600px")



    script(type='text/babel').
        var self = this,

        route = riot.route.create()

        self.mixin('change')

        self.isNew = false
        self.item = {}
        self.regions = []
        self.cities = []
        self.streets = []

        self.reload = e => {
            observable.trigger('measurement-edit', self.item.id)
        }

        observable.on('measurement-edit', id => {
            var params = {id}
            self.error = false
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()

            API.request({
                object: 'Measurement',
                method: 'Info',
                data: params,
                success(response) {
                    self.item = response
                    self.loader = false
                    self.update()
                }
            })
        })

        self.submit = () => {
            var params = self.item
            API.request({
                object: 'Measurement',
                method: 'Save',
                data: params,
                success(response) {
                    self.item = response
                    self.isNew = false
                    self.update()
                    popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                    observable.trigger('requests-reload')
                }
            })
        }

        self.changeCustomer = () => {
            modals.create('persons-list-select-modal',{
                type: 'modal-primary',
                size: 'modal-lg',
                submit() {
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()
                    if (items.length > 0) {
                        self.item.idUser = items[0].id
                        self.item.customer = items[0].name
                        self.item.phone = items[0].phone
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
                            self.item.phone = response.phone
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

        observable.on('measurement-new', () => {
            self.error = false
            self.isNew = true
            self.item = {sumDelivery: 0, discount: 0, idStatus: 2, addressStreet: '', addressBuilding: '' }
            self.item.dateDisplay = (new Date()).toLocaleString()
            self.getRegions()
            self.getZones()
            API.request({
                object: 'Measurement',
                method: 'Info',
                success(response) {
                    self.item.num = response.newNum
                    self.update()
                }
            })
        })

        self.getRegions = () => {
            API.request({
                object: 'AtdRegion',
                method: 'Fetch',
                success(response) {
                    self.regions = response.items
                    if (self.regions.length) {
                        self.item.idAddressRegion = self.regions[0].id
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
                        self.item.idAddressCity = self.cities[0].id
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

        self.geoFix = (e) => {

            self.item.addressBuilding = e.target.value
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

            API.request({
                object: 'AtdStreet',
                method: 'Info',
                data: { value: address, idCity: self.item.idAddressCity },
                success(response) {
                   self.item.dependent = response.dependent
                   self.item.longitude = response.longitude
                   self.item.latitude = response.latitude
                   if (!!response.idGeoZone) {
                       self.item.idGeoZone = response.idGeoZone
                       let placemark = new ymaps.Placemark([self.item.latitude, self.item.longitude], {
                           hintContent: 'Замер',
                           balloonContent: 'Замер'
                       });
                       mapYandex.geoObjects.add(placemark);
                       mapYandex.setCenter([self.item.latitude, self.item.longitude], 12);
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
            self.item.dependent = null
            self.item.longitude = null
            self.item.latitude = null
            self.item.addressStreet = null

            self.update()
            self.getCities(e.target.value)
        }

        self.cityChange = (e) => {

            self.streets = []
            self.item.dependent = null
            self.item.longitude = null
            self.item.latitude = null
            self.item.addressStreet = null
            self.item.idAddressCity = e.target.value

            self.update()
            self.getStreets(self.item.idAddressCity)
        }

        self.on('mount', () => {
            riot.route.exec()
        })

        ymaps.ready(init);
        var mapYandex;

        function init(){
            mapYandex = new ymaps.Map("map", {
                center: [55.76, 37.64],
                zoom: 10
            });
        }

    