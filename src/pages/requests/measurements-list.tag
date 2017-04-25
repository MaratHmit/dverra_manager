| import 'components/catalog.tag'
| import './simple-status-modal.tag'

measurements-list
    catalog(object='Measurement', search='true', sortable='true', cols='{ cols }', handlers='{ handlers }', reload='true',
        add='{ add }', remove='{ remove }', dblclick='{ edit }', store='requests-list', new-filter='true')
        #{'yield'}(to='filters')
            .well.well-sm
                .form-inline
                    .form-group
                        label.control-label От даты
                        datetime-picker.form-control(data-name='createdAt', data-sign='>=', format='DD.MM.YYYY')
                    .form-group
                        label.control-label До даты
                        datetime-picker.form-control(data-name='createdAt', data-sign='<=', format='DD.MM.YYYY')
                    .form-group
                        label.control-label Статус замера
                        select.form-control(data-name='status')
                            option(value='') Все
                            option(value='0') Новые
                            option(value='1') В работе
                            option(value='2') Завершенные

        #{'yield'}(to='head')
            button.btn.btn-warning(if='{ parent.isAllowedStatus }',
                onclick='{ handlers.setStatus }', title='Изменить статус', type='button')
                i.fa.fa-check
                |  Статус

        #{'yield'}(to="body")
            datatable-cell(name='id') { row.id }
            datatable-cell(name='date') { row.dateDisplay }
            datatable-cell(name='customer') { row.customer }
            datatable-cell(name='customerPhone') { row.customerPhone }
            datatable-cell(name='serviceDate') { row.serviceDate }
            datatable-cell(name='serviceAddress') { row.address }
            datatable-cell(name='serviceZone') { row.serviceZone }
            datatable-cell(name='status', class='{ handlers.statuses.colors[row.status]  } ')
                | { handlers.statuses.text[row.status]  }
            datatable-cell(name='note') { row.note }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Measurement'
        self.statuses = []
        self.statusesMap = { text: ['Новый', 'В работе', 'Завершен'], colors: ['bg-danger', 'bg-warning', 'bg-success'] }
        self.isAllowedStatus = false

        self.handlers = {
            statuses: self.statusesMap,
            onSelected(selectedRows) {
                self.isAllowedStatus = false
                if (selectedRows.length > 0) {
                    let item = selectedRows[0]
                    self.isAllowedStatus = (item.status != 2)
                }
            },
            setStatus() {
                let rows = this.tags.datatable.getSelectedRows()
                if (!rows.length)
                     return true

                let item = rows[0]
                modals.create('simple-status-modal', {
                    type: 'modal-primary',
                    status: item.status,
                    submit() {
                        let data = this.item
                        data.id = item.id
                        let _this = this
                        if (data.status != item.status) {
                            API.request({
                                object: 'Measurement',
                                method: 'Status',
                                data: data,
                                success(response) {
                                    item.status = data.status
                                    self.update()
                                },
                                complete() {
                                  _this.modalHide()
                                }
                            })
                        }
                    }
                })
            }
        }

        self.cols = [
            { name: 'id' , value: '#' },
            { name: 'date' , value: 'Дата заказа' },
            { name: 'customer' , value: 'Заказчик' },
            { name: 'customerPhone' , value: 'Телефон' },
            { name: 'serviceDate' , value: 'Дата замера' },
            { name: 'serviceAddress' , value: 'Адрес замера' },
            { name: 'serviceZone' , value: 'Район замера' },
            { name: 'status' , value: 'Статус' },
            { name: 'note' , value: 'Заметка' },
        ]

        self.edit = function (e) {
          riot.route(`/requests/measurements/${e.item.row.id}`)
        }

        self.add = () => riot.route(`/requests/measurements/new`)

        observable.on('measurements-reload', function () {
            self.tags.catalog.reload()
        })







