| import 'components/ckeditor.tag'
| import 'components/loader.tag'
| import 'pages/persons/persons-category-select-modal.tag'
| import 'pages/persons/person-balance-modal.tag'
| import 'pages/persons/persons-list-select-modal.tag'
| import 'pages/settings/add-fields/add-fields-edit-block.tag'
| import 'pages/persons/person-pet-modal.tag'
| import md5 from 'blueimp-md5/js/md5.min.js'

person-edit
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .btn-group
            a.btn.btn-default(href='#persons') #[i.fa.fa-chevron-left]
            button.btn.btn-default(if='{ checkPermission("contacts", "0010") }', onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { ['Редактирование контакта:', "[#" + item.id + "]", item.name].join(" ") }

        ul.nav.nav-tabs.m-b-2
            li.active #[a(data-toggle='tab', href='#person-edit-home') Информация]
            li(if='{ checkPermission("products", "1000") }') #[a(data-toggle='tab', href='#person-edit-groups') Группы]
            li(if='{ checkPermission("products", "1000") }') #[a(data-toggle='tab', href='#person-edit-pets') Животные]
            li(if='{ item.customFields && item.customFields.length }')
                a(data-toggle='tab', href='#person-edit-fields') Доп. информация

        form(action='', onchange='{ change }', onkeyup='{ change }', method='POST')
            .tab-content
                #person-edit-home.tab-pane.fade.in.active
                    .row
                        .col-md-2
                            .form-group
                                .well.well-sm
                                    image-select(name='imagePath', alt='0', size='256', value='{ item.imagePath }')
                        .col-md-10
                            .form-group
                                label.control-label Имя
                                input.form-control(name='name', type='text', value='{ item.name }')
                    .row
                        .col-md-6
                            .form-group
                                label.control-label Телефон
                                input.form-control(name='phone', type='text', value='{ item.phone }')
                        .col-md-6
                            .form-group(class='{ has-error: error.email }')
                                label.control-label Email
                                input.form-control(name='email', type='text', value='{ item.email }')
                                .help-block { error.email }
                    .row
                        .col-md-6
                            .form-group
                                label.control-label Логин
                                input.form-control(name='login', type='text', value='{ item.login }')
                        .col-md-6
                            .form-group
                                label.control-label Пароль
                                input.form-control(name='hash', type='password', value='{ item.hash }')
                    .row
                        .col-md-12
                            .checkbox
                                label
                                    input(type='checkbox', name='isActive', checked='{ item.isActive == 1 }')
                                    | Активен
                    .row
                        .col-md-12
                            .form-group
                                label Зарегистрирован:
                                    nbsp
                                    b { item.createdAt }

                #person-edit-groups.tab-pane.fade(if='{ checkPermission("products", "1000") }')
                    catalog-static(name='groups', cols='{ groupsCols }', rows='{ item.groups }', add='{ addGroup }',
                    remove='{ removeGroups }')
                        #{'yield'}(to='body')
                            datatable-cell(name='id') { row.id }
                            datatable-cell(name='name') { row.name }
                #person-edit-pets.tab-pane.fade(if='{ checkPermission("products", "1000") }')
                    catalog-static(name='pets', cols='{ petsCols }', rows='{ item.pets }', add='{ addEditPet }',
                    dblclick='{ addEditPet }', remove='{ removePets }')
                        #{'yield'}(to='body')
                            datatable-cell(name='imageUrlPreview')
                                img(width='32px', height='32px', src='{ row.imageUrlPreview }')
                            datatable-cell(name='birthday') { row.birthday }
                            datatable-cell(name='name') { row.name }
                            datatable-cell(name='weight') { row.weight }
                #person-edit-fields.tab-pane.fade(if='{ item.customFields && item.customFields.length }')
                    add-fields-edit-block(name='customFields', value='{ item.customFields }')

    script(type='text/babel').
        var self = this

        self.item = {}
        self.orders = []
        self.groupsSelectedCount = 0
        self.accountOperations = []

        self.mixin('permissions')
        self.mixin('validation')
        self.mixin('change')

        self.rules = {
            name: 'empty',
            email: {rules: [{type: 'email'}]}
        }

        self.afterChange = e => {
            let name = e.target.name
            delete self.error[name]
            self.error = {...self.error, ...self.validation.validate(self.item, self.rules, name)}
        }

        self.cols = [
            { name: 'id' , value: '#' },
            { name: 'dateOrder' , value: 'Дата заказа' },
            { name: 'amount' , value: 'Сумма' },
            { name: 'status' , value: 'Статус заказа' },
            { name: 'deliveryStatus' , value: 'Статус доставки' },
            { name: 'note' , value: 'Примечание' }
        ]

        self.groupsCols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'}
        ]

        self.petsCols = [
            {name: 'imageUrlPreview', value: 'Фото'},
            {name: 'birthday', value: 'Дата рождения'},
            {name: 'name', value: 'Наименование'},
            {name: 'weight', value: 'Вес (гр.)'}
        ]

        self.addGroup = () => {
            modals.create('persons-category-select-modal', {
                type: 'modal-primary',
                submit() {
                    self.item.groups = self.item.groups || []
                    let items = this.tags.catalog.tags.datatable.getSelectedRows()

                    let ids = self.item.groups.map(item => {
                        return item.id
                    })

                    items.forEach(item => {
                        if (ids.indexOf(item.id) === -1) {
                            self.item.groups.push(item)
                        }
                    })

                    self.update()
                    this.modalHide()
                }
            })
        }

        self.removeGroups = e => {
            self.groupsSelectedCount = 0
            self.item.groups = self.tags.groups.getUnselectedRows()
            self.update()
        }

        self.addEditPet = (e) => {
            let pet = {}
            if (e && e.item && e.item.row)
                pet = e.item.row
            modals.create('person-pet-modal', {
                type: 'modal-primary',
                pet,
                submit() {
                    let _this = this
                    _this.error = _this.validation.validate(_this.item, _this.rules)
                    if (!_this.error) {
                        if (e && e.item && e.item.row) {
                            if (_this.item.imagePath)
                                _this.item.imageUrlPreview = app.getImageUrl(_this.item.imagePath)
                            e.item.row = _this.item
                        } else {
                            if (_this.item.imagePath)
                                _this.item.imageUrlPreview = app.getImageUrl(_this.item.imagePath)
                            self.item.pets.push(_this.item)
                        }
                        _this.modalHide()
                        self.update()
                    }
                }
            })
        }

        self.submit = e => {
            var params = self.item
            self.error = self.validation.validate(params, self.rules)

            if (!self.error) {
                if (self.item && self.item.hash && self.item.hash.trim() === '')
                    delete self.item.hash

                API.request({
                    object: 'User',
                    method: 'Save',
                    data: params,
                    success(response) {
                        popups.create({title: 'Успех!', text: 'Контакт сохранен!', style: 'popup-success'})
                        self.item = response
                        self.item.hash = new Array(8).join(' ')
                        self.update()
                        observable.trigger('persons-reload')
                    }
                })
            }
        }

        self.reload = () => {
            observable.trigger('persons-edit', self.item.id)
        }

        observable.on('persons-edit', id => {
            var params = {id: id}
            self.error = false
            self.loader = true
            API.request({
                object: 'User',
                method: 'Info',
                data: params,
                success: (response, xhr) => {
                    self.item = response
                    self.item.hash = new Array(8).join(' ')
                    self.loader = false
                    self.update()
                },
                error(response) {
                    self.item = {}
                    self.loader = false
                    self.update()
                }
             })

        })


        self.on('mount', () => {
            riot.route.exec()
        })