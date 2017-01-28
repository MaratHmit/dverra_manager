| import './pko-modal.tag'

pko-list
    catalog(object='DocPKO', search='true', sortable='true', cols='{ cols }', handlers='{ handlers }', reload='true',
        remove='{ remove }',
        dblclick='{ pkoOpen }',
        before-success='{ getAggregation }', store='pko-list', new-filter='true')
        #{'yield'}(to='filters')
            .well.well-sm
                .form-inline
                    .form-group
                        label.control-label От даты
                        datetime-picker.form-control(data-name='date', data-sign='>=', format='DD.MM.YYYY')
                    .form-group
                        label.control-label До даты
                        datetime-picker.form-control(data-name='date', data-sign='<=', format='DD.MM.YYYY')
        #{'yield'}(to='head')
            button.btn.btn-warning(if='{ selectedCount > 0 }', onclick='{ handlers.print }', title='Печать', type='button')
                i.fa.fa-check
                |  Печать

        #{'yield'}(to="body")
            datatable-cell(name='num') { row.num }
            datatable-cell(name='date') { row.dateDisplay }
            datatable-cell(name='customer') { row.customer }
            datatable-cell(name='customerPhone') { row.customerPhone }
            datatable-cell(name='base') { row.base }
            datatable-cell(name='amount')
                span { (row.amount / 1).toLocaleString() } ₽

        #{'yield'}(to='aggregation')
            strong Сумма:
                span { (parent.totalAmount / 1 || 0).toLocaleString()  + " ₽  " }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')

        self.collection = 'DocPKO'

        self.cols = [
            { name: 'num' , value: '№' },
            { name: 'date' , value: 'Дата' },
            { name: 'customer' , value: 'Плательщик' },
            { name: 'customerPhone' , value: 'Телефон' },
            { name: 'base' , value: 'Основание' },
            { name: 'amount' , value: 'Сумма' },
        ]

        self.getAggregation = (response, xhr) => {
            self.totalAmount = response.totalAmount
        }

        self.handlers = {
            print() {
                let rows = this.tags.datatable.getSelectedRows()
                let item = rows[0]

                API.request({
                    object: 'DocPKO',
                    method: 'Info',
                    data: item,
                    success(response) {
                        if (response.url) {
                            window.open(response.url, '_blank')
                        }
                    }
                })
            }
        }

        self.pkoOpen = (e) => {
            let item = e.item.row
            modals.create('pko-modal', {
                type: 'modal-primary',
                idUser: item.idUser,
                customer: item.customer,
                base: item.base,
                amount: item.amount,
                submit() {
                    let data = this.item
                    let params = { id: item.id, amount: data.amount }
                    this.modalHide()
                    if (data.amount > 0) {
                        API.request({
                            object: 'DocPKO',
                            method: 'Save',
                            data: params,
                            success() {
                                popups.create({title: 'Успех!', text: 'Изменения сохранены!', style: 'popup-success'})
                                observable.trigger('pko-reload')
                            }
                        })
                    }
                }
            })
        }

        observable.on('pko-reload', function () {
            self.tags.catalog.reload()
        })
