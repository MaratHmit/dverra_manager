| import 'components/loader.tag'
| import 'pages/schedule/schedule-modal.tag'
| import 'pages/persons/person-new-modal.tag'
| import 'inputmask'

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
                                    label.control-label Улица
                                    input.form-control(name='addressStreet', value='{ item.addressStreet }')
                            .col-md-1
                                .form-group
                                    label.control-label Дом/строение
                                    input.form-control(name='addressBuilding', value='{ item.addressBuilding }')
                            .col-md-1
                                .form-group
                                    label.control-label Квартира
                                    input.form-control(name='addressApartment', value='{ item.addressApartment }')
                            .col-md-4
                                .form-group
                                    label.control-label Примечание по адресу
                                    input.form-control(name='addressNote', value='{ item.addressNote }')
            .row
                .col-md-3
                    .form-group
                        label.control-label Дата и время выполнения замера
                        .input-group
                            input.form-control(name='measurementDate',
                            value='{ item.measurementDate }', readonly)
                            span.input-group-addon(onclick='{ getMeasurementDate }')
                                i.fa.fa-calendar
                .col-md-9
                    .form-group
                        label.control-label Примечание по замеру
                        input.form-control(name='note', value='{ item.note }')



    script(type='text/babel').
        var self = this,

        route = riot.route.create()

        self.mixin('change')

        self.isNew = false
        self.item = {}
        self.regions = []
        self.cities = []

        self.reload = e => {
            observable.trigger('request-edit', self.item.id)
        }

        observable.on('request-edit', id => {
            var params = {id}
            self.error = false
            self.isNew = false
            self.item = {}
            self.loader = true
            self.update()

            API.request({
                object: 'Request',
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
            self.item = {sumDelivery: 0, discount: 0, idStatus: 2}
            self.item.dateDisplay = (new Date()).toLocaleString()
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
                    self.isNew = false
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
                    self.update()
                }
            })
        }

        self.regionChange = (e) => {
            self.getCities(e.target.value)
        }

        self.on('mount', () => {
            self.getRegions()
            riot.route.exec()
        })

    