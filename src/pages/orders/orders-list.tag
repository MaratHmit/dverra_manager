| import 'components/catalog.tag'
| import '../pko/pko-modal.tag'
| import './order-status-modal.tag'

orders-list

    catalog(object='Order', search='true', sortable='true', cols='{ cols }', handlers='{ handlers }', reload='true',
        add='{ permission(add, "orders", "0100") }',
        remove='{ permission(remove, "orders", "0001") }',
        dblclick='{ permission(orderOpen, "orders", "1000") }',
        before-success='{ getAggregation }',store='orders-list', new-filter='true')
        #{'yield'}(to='filters')
            .well.well-sm
                .form-inline
                    .form-group
                        label.control-label От даты
                        datetime-picker.form-control(data-name='date', data-sign='>=', format='DD.MM.YYYY')
                    .form-group
                        label.control-label До даты
                        datetime-picker.form-control(data-name='date', data-sign='<=', format='DD.MM.YYYY')
                    .form-group
                        label.control-label Статус заказа
                        select.form-control(data-name='idStatus')
                            option(value='') Все
                            option(each='{ parent.statuses }', value='{ id }', no-reorder) { name }
        #{'yield'}(to='head')
            .dropdown(if='{ selectedCount > 0 }', style='display: inline-block;')
                button.btn.btn-default.dropdown-toggle(data-toggle="dropdown", aria-haspopup="true", type='button', aria-expanded="true")
                    | Документы&nbsp;
                    span.caret
                ul.dropdown-menu
                    li(onclick='{ handlers.createPKO }', class='{ disabled: !parent.isAllowedPKO }')
                        a(href='#')
                            |  Приходно-кассовый ордер
                    li(onclick='{ handlers.printContract }', class='{ disabled: selectedCount == 0 }')
                        a(href='#')
                            |  Договор
            button.btn.btn-warning(if='{ parent.isAllowedStatus }', onclick='{ handlers.setStatus }', title='Изменить статус', type='button')
                i.fa.fa-check
                |  Статус

        #{'yield'}(to="body")
            datatable-cell(name='num') { row.num }
            datatable-cell(name='date') { row.dateDisplay }
            datatable-cell(name='customer') { row.customer }
            datatable-cell(name='customerPhone') { row.customerPhone }
            datatable-cell(name='serviceDate') { row.serviceDate }
            datatable-cell(name='serviceAddress') { row.address }
            datatable-cell(name='debt', style='background-color:{ red: row.debt > 0  } ')
                span { (row.debt / 1).toLocaleString() } ₽
            datatable-cell(name='amount')
                span { (row.amount / 1).toLocaleString() } ₽
            datatable-cell(name='status', style='background-color:{ handlers.statuses.colors[row.idStatus]  } ')
                | { handlers.statuses.text[row.idStatus]  }
            datatable-cell(name='note') { row.note }

        #{'yield'}(to='aggregation')
            strong Сумма заказов:
                span { (parent.totalAmount / 1 || 0).toLocaleString()  + " ₽  " }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')

        self.collection = 'Order'
        self.statuses = []
        self.statusesMap = { text: {}, colors: {} }
        self.isAllowedPKO = false
        self.isAllowedStatus = false

        self.handlers = {
            statuses: self.statusesMap,
            onSelected(selectedRows) {
                self.isAllowedPKO = false
                self.isAllowedStatus = false
                if (selectedRows.length > 0) {
                    let item = selectedRows[0]
                    self.isAllowedPKO = (item.paid < 2)
                }
                if (selectedRows.length > 0) {
                    let item = selectedRows[0]
                    self.isAllowedStatus = (item.status != 'canceled' && item.status != 'completed')
                }
            },
            createPKO() {
                let rows = this.tags.datatable.getSelectedRows()
                let item = rows[0]
                let [dateDisplay, ]= item.dateDisplay.split(" ")
                modals.create('pko-modal', {
                    type: 'modal-primary',
                    idUser: item.idUser,
                    customer: item.customer,
                    base: "Заказ № " + item.num + " от " + dateDisplay,
                    amount: item.debt,
                    submit() {
                        let data = this.item
                        data.idOrder = item.id

                        this.modalHide()
                        if (data.amount > 0) {
                            API.request({
                                object: 'DocPKO',
                                method: 'Save',
                                data: data,
                                success(response) {
                                    if (response.url)
                                        window.open(response.url, '_blank')
                                    popups.create({title: 'Успех!', text: 'Платеж сохранен!', style: 'popup-success'})
                                    observable.trigger('orders-reload')
                                }
                            })
                        }
                    }
                })
                $("#pko-amount").focus();
            },
            printContract() {
                let rows = this.tags.datatable.getSelectedRows()
                let item = rows[0]
                API.request({
                    object: 'Order',
                    method: 'Print',
                    data: item,
                    success(response) {
                        if (response.url)
                            window.open(response.url, '_blank')
                    }
                })
            },
            setStatus() {
                let rows = this.tags.datatable.getSelectedRows()
                if (!rows.length)
                    return true

                let item = rows[0]
                modals.create('order-status-modal', {
                    type: 'modal-primary',
                    statuses: self.statuses,
                    idStatus: item.idStatus,
                    submit() {
                        let data = this.item
                        data.id = item.id
                        let _this = this
                        if (data.idStatus != item.idStatus) {
                            API.request({
                                object: 'Order',
                                method: 'Status',
                                data: data,
                                success(response) {
                                    item.idStatus = data.idStatus
                                    self.update()
                                },
                                error(response) {
                                    modals.create('bs-alert', {
                                        type: 'modal-danger',
                                        title: 'Ошибка учета',
                                        text: response,
                                        buttons: [
                                            {action: 'close', title: 'Закрыть', style: 'btn-danger'},
                                        ],
                                        callback: function (action) {
                                            if (action === 'close')
                                                this.modalHide()
                                        }
                                    })
                                },
                                complete() {
                                    _this.modalHide()
                                }
                            })
                        } else _this.modalHide()
                    }
                })
            }
        }

        self.cols = [
            { name: 'num' , value: '№' },
            { name: 'dateOrder' , value: 'Дата заказа' },
            { name: 'customer' , value: 'Заказчик' },
            { name: 'customerPhone' , value: 'Телефон' },
            { name: 'serviceDate' , value: 'Дата доставки' },
            { name: 'serviceAddress' , value: 'Адрес доставки' },
            { name: 'debt' , value: 'Долг' },
            { name: 'amount' , value: 'Сумма' },
            { name: 'status' , value: 'Статус заказа' },
            { name: 'note' , value: 'Примечание' },
        ]

        self.orderOpen = function (e) {
           // if (e.item.row.status != 'canceled' && e.item.row.status != 'completed')
                riot.route(`/orders/${e.item.row.id}`)
        }

        self.getAggregation = (response, xhr) => {
            self.totalAmount = response.totalAmount
        }

        self.add = () => riot.route('/orders/new')

        self.remove = (e, items, tag) => {
            let params = {id: items[0]}

            modals.create('bs-alert', {
                type: 'modal-danger',
                title: 'Предупреждение',
                text: 'Отменить выбранный заказ?',
                size: 'modal-sm',
                    buttons: [
                        {action: 'yes', title: 'Да', style: 'btn-default'},
                        {action: 'no', title: 'Нет', style: 'btn-danger'},
                    ],
                callback(action) {
                    if (action === 'yes') {
                        API.request({
                            object: 'Order',
                            method: 'Cancel',
                            data: params,
                            success(response) {
                                popups.create({title: 'Заказ успешно отменен!', style: 'popup-success'})
                                tag.reload()
                            }
                        })
                    }
                    this.modalHide()
                }
            })
        }

        self.getStatuses = () => {
            API.request({
                object: 'OrderStatus',
                method: 'Fetch',
                success(response) {
                    self.statuses = response.items
                    self.statuses.forEach(function(item) {
                        self.statusesMap.text[item.id] = item.name
                        self.statusesMap.colors[item.id] = "#" + item.color
                    })
                    self.update()
                }
            })
        }

        observable.on('orders-reload', function () {
            self.tags.catalog.reload()
        })

        self.getStatuses()



