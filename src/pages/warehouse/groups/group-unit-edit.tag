| import './groups-units-list-modal.tag'

group-unit-edit
    loader(if='{ loader }')
    div
        .btn-group
            a.btn.btn-default(href='#warehouse/groups') #[i.fa.fa-chevron-left]
            button.btn.btn-default(onclick='{ submit }', type='button')
                i.fa.fa-floppy-o
                |  Сохранить
            button.btn.btn-default(onclick='{ reload }', title='Обновить', type='button')
                i.fa.fa-refresh
        .h4 { isNew ? item.name || 'Новая группа' : item.name || 'Редактирование группы' }
        form(if='{ !loader }', onchange='{ change }', onkeyup='{ change }')
            .row
                .col-md-6: .form-group(class='{ has-error: error.name }')
                    label.control-label Наименование
                    input.form-control(name='name', type='text', value='{ item.name }')
                    .help-block { error.name }
                .col-md-6: .form-group
                    label.control-label Родительская группа
                    .input-group
                        input.form-control(name='nameParent', value='{ item.nameParent }', readonly='{ true }')
                        span.input-group-addon.text-primary(onclick='{ selectGroup }')
                            i.fa.fa-plus
                        span.input-group-addon.text-primary(onclick='{ removeGroup }')
                            i.fa.fa-times

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
                    object: 'UnitGroup',
                    method: 'Save',
                    data: self.item,
                    success(response) {
                        self.item = response
                        popups.create({title: 'Успех!', text: 'Группа сохранена!', style: 'popup-success'})
                        observable.trigger('groups-reload')
                        self.update()
                    }
                })
            }
        }

        self.selectGroup = () => {
            modals.create('groups-units-list-modal', {
                type: 'modal-primary',
                submit() {
                    let items = this.tags['catalog-tree'].tags.treeview.getSelectedNodes()

                    if (items.length && items[0].id != self.item.id) {
                        self.item.idParent = items[0].id
                        self.item.nameParent = items[0].name
                        self.update()
                        this.modalHide()
                    }
                }
            })
        }

        self.removeGroup = () => {
            self.item.idParent = null
            self.item.nameParent = null
        }

        self.reload = () => observable.trigger('groups-edit', self.item.id)

        observable.on('groups-edit', id => {
            self.error = false
            self.loader = true
            self.item = {}
            self.isNew = false
            self.update()

            API.request({
                object: 'UnitGroup',
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