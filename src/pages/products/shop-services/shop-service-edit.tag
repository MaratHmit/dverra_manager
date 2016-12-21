shop-service-edit
    loader(if='{ loader }')
    div
        .btn-group
            a.btn.btn-default(href='#products/shop-services') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? item.name || 'Новая услуга' : item.name || 'Редактирование услуги' }
        form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
            .form-group(class='{ has-error: error.name }')
                .row                        .
                    .col-md-4
                        .form-group
                            label.control-label Наименование услуги
                            input.form-control(name='name', type='text', value='{ item.name }')
                            .help-block { error.name }
                    .col-md-2
                        .form-group
                            label.control-label Цена
                            input.form-control(name='price', type='number', min='0', step='1', value='{ parseFloat(item.price) }')
                    .col-md-2
                        .form-group
                            label.control-label Цена/км
                            input.form-control(name='priceKm', type='number', min='0', step='1', value='{ parseFloat(item.priceKm) }')

                    .col-md-2
                        .form-group
                            label.control-label Порядок вывода
                            input.form-control(name='sort', type='number', min='0', step='1', value='{ item.sort }')
                .row
                    .col-md-2
                        .form-group
                            .checkbox-inline
                                label
                                    input(type='checkbox', name='isDistance', checked='{ item.isDistance }')
                                    | Зависит от расстояния
                .row
                    .col-md-2
                        .form-group
                            .checkbox-inline
                                label
                                    input(type='checkbox', name='isActive', checked='{ item.isActive }')
                                    | Отображать на сайте


    script(type='text/babel').
        var self = this

        self.mixin('validation')
        self.mixin('permissions')
        self.mixin('change')
        self.item = {}

        self.rules = {
            name: 'empty',
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.submit = () => {
            self.error = self.validation.validate(self.item, self.rules)

            if (!self.error) {
                API.request({
                    object: 'ShopService',
                    method: 'Save',
                    data: self.item,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Услуга сохранена!', style: 'popup-success'})
                        if (self.isNew)
                            riot.route(`products/shop-services/${self.item.id}`)
                        observable.trigger('shop-services-reload')
                        self.update()
                    }
                })
            }
        }

        self.reload = () => observable.trigger('shop-service-edit', self.item.id)

        observable.on('shop-service-new', () => {
           self.error = false
           self.item = { isActive: true, price: 0.00, priceKm: 0.00 }
           self.isNew = true
           self.update()
        })

        observable.on('shop-services-edit', id => {
            self.error = false
            self.loader = true
            self.item = {}
            self.isNew = false
            self.update()

            API.request({
                object: 'ShopService',
                method: 'Info',
                data: {id},
                success(response) {
                    self.item = response
                },
                complete() {
                    self.loader = false
                    self.update()
                }
            })
        })


