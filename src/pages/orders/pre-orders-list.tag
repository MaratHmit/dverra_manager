| import 'components/catalog.tag'

pre-orders-list

    catalog(object='PreOrder', search='true', sortable='true', cols='{ cols }', reload='true', handlers='{ handlers }',
    remove='{ permission(remove, "orders", "0001") }')
        #{'yield'}(to="body")
            datatable-cell(name='id', class='{ handlers.sendMail.colors[row.sendMail] }') { row.id }
            datatable-cell(name='createdAt') { row.createdAt }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='email') { row.email }
            datatable-cell(name='phone') { row.phone }
            datatable-cell(name='product') { row.product }
            datatable-cell(name='count') { row.count }
            datatable-cell(name='sendMail', class='{ handlers.sendMail.colors[row.sendMail] }')
                i(class='fa { row.sendMail ? "fa-check " : null } ')

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'PreOrder'

        self.sendMail = {
            colors: {
                0: 'bg-success', 1: 'bg-danger'
            }
        }

        self.handlers = {
           sendMail: self.sendMail,
        }

        self.cols = [
            { name: 'id' , value: '#' },
            { name: 'createdAt' , value: 'Дата заказа' },
            { name: 'name' , value: 'Заказчик' },
            { name: 'email' , value: 'Email заказчика' },
            { name: 'phone' , value: 'Телефон заказчика' },
            { name: 'product' , value: 'Наименование товара' },
            { name: 'count' , value: 'Кол-во' },
            { name: 'sendMail' , value: 'Отправлено письмо' },
        ]

        observable.on('orders-reload', function () {
            self.tags.catalog.reload()
        })



