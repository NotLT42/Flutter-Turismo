import 'package:flutter/material.dart';

import '../dao/package_dao.dart';
import '../models/package.dart';
import '../services/package_service.dart';

class list_view extends StatefulWidget {
  const list_view({super.key});

  @override
  State<list_view> createState() => _list_viewState();
}

class _list_viewState extends State<list_view> {

  final _sitio = {
    'S001': 'Machu Picchu',
    'S002': 'Ayacucho',
    'S003': 'Chichen Itza',
    'S004': 'Cristo Redentor',
    'S005': 'Islas Malvinas',
    'S006': 'Muralla China',
  };

  String _sitioSeleccionado = '';

  final _tipo = {
    '1': 'Viajes',
    '2': 'Hospedaje',
  };

  String _tipoSeleccionado = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paquetes Turísticos'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  items: _sitio.keys.map((String key){
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text(_sitio[key]!),
                    );
                  }).toList(),
                  onChanged: (String? value){
                    setState(() {
                      _sitioSeleccionado = value!;
                    });
                  },
                  hint:  Text(_sitioSeleccionado == '' ? 'Seleccione un sitio' : _sitio[_sitioSeleccionado]!),
                ),
                DropdownButton<String>(
                    items: _tipo.keys.map((String key){
                      return DropdownMenuItem<String>(
                        value: key,
                        child: Text(_tipo[key]!),
                      );
                    }).toList(),
                    onChanged: (String? value){
                      setState(() {
                        _tipoSeleccionado = value!;
                      });
                    },
                    hint: Text(_tipoSeleccionado == '' ? 'Seleccione un tipo' : _tipo[_tipoSeleccionado]!)
                ),
              ],
            ),
            ElevatedButton(
              onPressed: (){
                setState(() {
                  _sitioSeleccionado = _sitioSeleccionado;
                  _tipoSeleccionado = _tipoSeleccionado;

                });
              },
              child: const Text('Buscar'),
            ),
            Expanded(
              child: PackageList(site: _sitioSeleccionado, type: _tipoSeleccionado),
            ),
          ],
        ),
      ),
    );
  }
}

class PackageList extends StatefulWidget {
  const PackageList({super.key, required this.site, required this.type});
  final String site;
  final String type;

  @override
  State<PackageList> createState() => _PackageListState();
}

class _PackageListState extends State<PackageList> {

  List<Package> packages = [];
  final _packageService = PackageService();


  initialize() async{
    if(widget.site.isEmpty || widget.type.isEmpty){
      return;
    }
    final result = await _packageService.getPackagesBySiteAndType(widget.site, widget.type);
    setState(() {
      packages = result;
    });
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    if(widget.site.isEmpty || widget.type.isEmpty){
      return const Center(
        child: Text('Seleccione un sitio y un tipo de paquete'),
      );
    }

    return FutureBuilder<List<Package>>(
        future: _packageService.getPackagesBySiteAndType(widget.site, widget.type),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
          }else if(snapshot.hasError){

            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }else{
            packages = snapshot.data!;
            return ListView.builder(
                itemCount: packages.length,
                itemBuilder: (context, index){
                  return PackageItem(package: packages[index]);
                }
            );
          }
        }


    );

  }
}


class PackageItem extends StatefulWidget {

  const PackageItem({super.key, required this.package});

  final Package package;

  @override
  State<PackageItem> createState() => _PackageItemState();
}

class _PackageItemState extends State<PackageItem> {

  bool _isFavorite = false;
  final _packageDao = PackageDao();

  initialize() async{
    _isFavorite = await _packageDao.isFavorite(widget.package.idProducto);
    if(mounted){
      setState(() {

      });
    }
  }
  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(widget.package.nombre),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.package.descripcion),
            Text(widget.package.ubicacin),
          ],
        ),
        leading: Image.network(widget.package.imagen),
        trailing: IconButton(
          onPressed: (){
            setState(() {
              _isFavorite = !_isFavorite;
            });
            if(_isFavorite){
              _packageDao.insertPackage(widget.package);
            }else{
              _packageDao.deletePackage(widget.package.idProducto);

            }
          },
          icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
          color: _isFavorite ? Colors.red : Colors.grey,
        ),
      ),
    );
  }
}