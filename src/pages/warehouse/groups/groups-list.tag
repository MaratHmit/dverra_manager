| import 'pages/products/groups/group-new-modal.tag'
| import 'components/catalog-tree.tag'

groups-units-list
    catalog-tree(object='UnitGroup', label-field='{ "name" }', children-field='{ "childs" }',
        add='{ add }',
        remove='{ remove }',
        handlers='{ handlers }', reload='true', search='true' )
        #{'yield'}(to='after')
            span { this[parent.childrenField].length ? "[" + this[parent.childrenField].length + "]" : "" }
            form.form-inline.pull-right
                button.btn.btn-default(type='button', onclick='{ handlers.open }')
                    i.fa.fa-pencil.text-primary
                button.btn.btn-default(type='button', onclick='{ handlers.add }')
                    i.fa.fa-plus.text-success
                button.btn.btn-default(type='button', onclick='{ handlers.remove }')
                    i.fa.fa-trash.text-danger

    style(scoped).
        :scope {
            position: relative;
            display: block;
        }

        treenodes .treenode {
            padding: 2px;
            width: 100%;
            display: inline-block;
            line-height: 2.2;
        }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'UnitGroup'

        self.add = (e) => {
            e.stopPropagation()

            var id, item
            if (e.item && e.item.id) {
                id = e.item.id
                item = e.item
            }

            modals.create('group-new-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (_this.name.value.toString().trim() != '' && !_this.error) {

                        var params, sort, childs

                        if (item) {
                            sort = item['childs'].length
                            item['childs'] = item['childs'] || []
                            childs = item['childs']
                        } else {
                              sort = self.tags['catalog-tree'].nodes.length
                              self.tags['catalog-tree'].nodes = self.tags['catalog-tree'].nodes || []
                              childs = self.tags['catalog-tree'].nodes
                        }

                        if (id)
                            params = {name: _this.name.value, idParent: id, sort}
                        else params = {name: _this.name.value, sort}

                        API.request({
                            object: 'UnitGroup',
                            method: 'Save',
                            data: params,
                            success(response) {
                                _this.modalHide()
                                childs.push(response)
                                popups.create({
                                    title: 'Успех!',
                                    text: 'Группа добавлена',
                                    style: 'popup-success'
                                })
                                self.tags['catalog-tree'].update()
                            }
                        })
                    }
                }
            })
        }

        self.removeNode = (e) => {
            e.stopPropagation()
            var self = this,
            params = {ids: [e.item.id]}

            modals.create('bs-alert', {
                type: 'modal-danger',
                title: 'Предупреждение',
                text: 'Вы точно хотите удалить эту группу?',
                size: 'modal-sm',
                buttons: [
                    {action: 'yes', title: 'Удалить', style: 'btn-danger'},
                    {action: 'no', title: 'Отмена', style: 'btn-default'},
                ],
                callback(action) {
                    if (action === 'yes') {
                        API.request({
                            object: 'UnitGroup',
                            method: 'Delete',
                            data: params,
                            success(response) {
                               if (e.item.__parent__ instanceof Array) {
                                   e.item.__parent__.splice(e.item.__parent__.indexOf(e.item), 1)
                               } else if (e.item.__parent__ instanceof Object) {
                                    e.item.__parent__['childs'].splice(e.item.__parent__['childs'].indexOf(e.item), 1)
                               }

                                popups.create({title: 'Успешно удалено!', style: 'popup-success'})
                                self.tags['catalog-tree'].update()
                            }
                        })
                    }
                    this.modalHide()
                }
            })
        }

        function open(e) {
            e.stopPropagation()
            riot.route(`/warehouse/groups/${e.item.id}`)
        }

        self.handlers = {
            add: self.add,
            open: open,
            remove: self.removeNode
        }

        observable.on('groups-reload', () => {
            self.tags['catalog-tree'].reload()
        })