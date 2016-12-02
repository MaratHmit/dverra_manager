| import 'components/catalog.tag'

payments-list

    catalog(object='Payment', search='true', sortable='true', cols='{ cols }', reload='true', , store='payments-list'
    add='{ permission(add, "payments", "0100") }',
    remove='{ permission(remove, "payments", "0001") }',
    dblclick='{ permission(paymentOpen, "payments", "1000") }',
    before-success='{ getAggregation }')
        #{'yield'}(to='filters')
            .well.well-sm
                .form-inline
                    .form-group
                        label.control-label От даты
                        datetime-picker.form-control(data-name='docDate', data-sign='>=', format='YYYY-MM-DD')
                    .form-group
                        label.control-label До даты
                        datetime-picker.form-control(data-name='docDate', data-sign='<=', format='YYYY-MM-DD')
                    .form-group
                        label.control-label Назначение
                        select.form-control(data-name='paymentTarget')
                            option(value='') Все
                            option(value='0') Оплата заказа
                            option(value='1') Пополнение счета
                    .form-group
                        .checkbox-inline
                            label
                                input(type='checkbox', data-name='paymentType', data-bool='1,0', data-sign='>=')
                                | Поступления
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='num') { row.num }
            datatable-cell(name='date') { row.date }
            datatable-cell(name='paymentTarget') { row.paymentTarget ? 'Пополнение счёта' : 'Оплата заказа'  }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='payer') { row.payer }
            datatable-cell(name='amount') { row.amount }
            datatable-cell(name='idOrder') { row.idOrder }
            datatable-cell(name='note') { row.note }
        #{'yield'}(to='aggregation')
            strong Сумма платежей: { (parent.totalAmount || 0) + " " }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Payment'
        self.totalAmount = 0

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'num', value: '№'},
            {name: 'date', value: 'Дата'},
            {name: 'paymentTarget', value: 'Назначение'},
            {name: 'name', value: 'Наименование'},
            {name: 'payer', value: 'Плательщик'},
            {name: 'amount', value: 'Сумма'},
            {name: 'idOrder', value: '№ заказа'},
            {name: 'note', value: 'Примечание'}
        ]

        self.getAggregation = (response, xhr) => {
            self.totalAmount = response.totalAmount
        }

        self.add = () => riot.route('/payments/new')

        self.paymentOpen = e => {
            riot.route(`/payments/${e.item.row.id}`)
        }

        self.paymentOpenItem = id => {
            riot.route(`/payments/${id}`)
        }

        observable.on('payments-reload', () => {
            self.tags.catalog.reload()
        })