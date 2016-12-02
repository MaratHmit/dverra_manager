| import './person-category-new-modal.tag'

persons-categories-list
    catalog(search='true', sortable='true', object='UserGroup', cols='{ cols }', reload='true',
    add='{ permission(addEdit, "contacts", "0100") }',
    remove='{ permission(remove, "contacts", "0001") }',
    dblclick='{ permission(addEdit, "contacts", "1000") }', store='persons-category-list')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'UserGroup'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
        ]

        self.addEdit = e => {
            let item = {}
            if (e.item && e.item.row)
                item = e.item.row

            modals.create('person-category-new-modal', {
                type: 'modal-primary',
                item,
                submit() {
                    let _this = this

                    API.request({
                        object: 'UserGroup',
                        data: _this.item,
                        method: 'Save',
                        success(response) {
                            observable.trigger('persons-category-reload')
                            popups.create({title: 'Успех!', text: 'Категория сохранена!', style: 'popup-success'})
                            _this.modalHide()
                        }
                    })
                }
            })

        }

        observable.on('persons-category-reload', () => self.tags.catalog.reload())