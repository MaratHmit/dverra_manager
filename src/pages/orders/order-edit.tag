| import 'components/datetime-picker.tag'
| import 'pages/settings/delivery/delivery-list-modal.tag'
| import 'pages/payments/payments-list-modal.tag'
| import 'pages/products/products/offers-list-select-modal.tag'
| import 'pages/products/shop-services/shop-services-list-select-modal.tag'
| import 'pages/schedule/schedule-modal.tag'
| import 'components/loader.tag'

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
                        .help-block { error.idUser }
                .col-md-3
                    .form-group
                        label.control-label Статус
                        select.form-control(name='idStatus')
                            option(each='{ statuses }', value='{ id }',
                            selected='{ id == item.idStatus }', no-reorder) { name }
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
                    .h4 Суммы
                    .row
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
                    .h4 Доп. параметры заказа
                    .row
                        .col-md-3
                            .form-group
                                label.control-label Адрес выполнения услуг
                                input.form-control(name='serviceAddress', value='{ item.serviceAddress }')
                        .col-md-3
                            .form-group
                                label.control-label Дата и время выполнения услуг
                                .input-group
                                    input.form-control(name='serviceDate',
                                        value='{ item.serviceDate }', readonly)
                                    span.input-group-addon(onclick='{ getServiceDate }')
                                        i.fa.fa-calendar
                        .col-md-6
                            .form-group
                                label.control-label Примечание
                                input.form-control(name='note', value='{ item.note }')


    script(type='text/babel').
        var self = this,
            route = riot.route.create()


        self.isNew = false
        self.item = {}
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
                modals.create('offers-list-select-modal', {
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
                                    self.item.items.push({...item, count: 1, discount: 0, id: null, idOffer: item.id})
                            })
                            self.update()
                            _this.modalHide()
                            let event = document.createEvent('Event')
                            event.initEvent('change', true, true)
                            self.tags.items.root.dispatchEvent(event)
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

        self.getStatuses = () => {
            let data = { sortBy: "id", sortOrder: "asc", limit: 1000 }
            API.request({
                object: 'OrderStatus',
                data: data,
                method: 'Fetch',
                success(response) {
                    self.statuses = response.items
                    if (!self.item.idStatus) {
                        self.statuses.forEach((item) => {
                            if (item.code == "new") {
                                self.item.idStatus = item.id
                                return
                            }
                        })
                    }
                    self.update()
                }
            })
        }

        self.getServiceDate = () => {
            modals.create('schedule-modal',{
                serviceDate: self.item.serviceDate,
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
            API.request({
                object: 'Order',
                method: 'Info',
                success(response) {
                    self.item.num = response.newNum
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
                    self.loader = false
                    self.update()
                }
            })
        })

        self.on('mount', () => {
            riot.route.exec()
        })

        self.getStatuses()