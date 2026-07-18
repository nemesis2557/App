import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/custom_logo.dart';
import '../widgets/pet_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final petsList = appState.filteredPets;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF7F1),
        elevation: 0,
        toolbarHeight: 90,
        title: Row(
          children: [
            const CustomLogo(size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Colitas Petshop",
                  style: TextStyle(
                    fontFamily: 'Baloo 2',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF382B4A),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Color(0xFF6FD9BE)),
                    const SizedBox(width: 4),
                    Text(
                      "Andahuaylas, Apurímac",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: const Color(0xFF382B4A).withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => appState.fetchPets(),
        color: const Color(0xFF7C5CBF),
        backgroundColor: const Color(0xFFFBF7F1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Buscador
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF382B4A).withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => appState.setSearchQuery(value),
                  style: const TextStyle(fontFamily: 'Inter', color: Color(0xFF382B4A)),
                  decoration: InputDecoration(
                    hintText: "Buscar por nombre, lugar o raza...",
                    hintStyle: TextStyle(
                      fontFamily: 'Inter',
                      color: const Color(0xFF382B4A).withOpacity(0.4),
                      fontSize: 14,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF7C5CBF)),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Color(0xFF382B4A)),
                            onPressed: () {
                              _searchController.clear();
                              appState.setSearchQuery('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Chips de filtro
              Row(
                children: [
                  _buildFilterChip(context, "Todos"),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, "Perdido"),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, "Encontrado"),
                ],
              ),
              const SizedBox(height: 16),
              
              // Título de la lista
              const Text(
                "Reportes Recientes",
                style: TextStyle(
                  fontFamily: 'Baloo 2',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF382B4A),
                ),
              ),
              const SizedBox(height: 8),
              
              // Lista de Mascotas
              Expanded(
                child: appState.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C5CBF)),
                        ),
                      )
                    : petsList.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                              const Icon(
                                Icons.sentiment_dissatisfied,
                                size: 64,
                                color: Color(0xFFE8935A),
                              ),
                              const SizedBox(height: 16),
                              const Center(
                                child: Text(
                                  "No se encontraron reportes",
                                  style: TextStyle(
                                    fontFamily: 'Baloo 2',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF382B4A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: Text(
                                  "Intenta cambiar los filtros o la búsqueda.",
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    color: const Color(0xFF382B4A).withOpacity(0.6),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: petsList.length,
                            itemBuilder: (context, index) {
                              return PetCard(pet: petsList[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label) {
    final appState = Provider.of<AppState>(context);
    final bool isSelected = appState.filterState == label;
    final Color selectedColor = const Color(0xFF7C5CBF);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          appState.setFilterState(label);
        }
      },
      selectedColor: selectedColor,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontFamily: 'Inter',
        color: isSelected ? Colors.white : const Color(0xFF382B4A),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.transparent : const Color(0xFFE5DED5),
          width: 1,
        ),
      ),
    );
  }
}
