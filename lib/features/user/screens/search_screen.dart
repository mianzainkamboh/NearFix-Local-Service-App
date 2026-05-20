import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/provider_service.dart';
import '../../../core/services/service_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final ProviderService _providerService = ProviderService();
  final ServiceService _serviceService = ServiceService();
  List<Map<String, dynamic>> _providerResults = [];
  List<Map<String, dynamic>> _serviceResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    final providers = await _providerService.searchProviders(query);
    final services = await _serviceService.searchServices(query);

    if (mounted) {
      setState(() {
        _providerResults = providers;
        _serviceResults = services;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Search providers or services...',
                filled: true,
                fillColor: AppColors.surface,
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: AppColors.primary),
                  onPressed: _performSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Results
          if (_isSearching)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_hasSearched && _providerResults.isEmpty && _serviceResults.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: AppColors.textLight),
                    const SizedBox(height: 16),
                    const Text('No results found', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    const Text('Try different keywords', style: TextStyle(color: AppColors.textLight)),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                children: [
                  if (_providerResults.isNotEmpty) ...[
                    const Text('Providers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._providerResults.map((p) => _buildProviderTile(p)),
                    const SizedBox(height: 16),
                  ],
                  if (_serviceResults.isNotEmpty) ...[
                    const Text('Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ..._serviceResults.map((s) => _buildServiceTile(s)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProviderTile(Map<String, dynamic> provider) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.providerDetail, arguments: {'providerId': provider['uid']}),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 24, backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider['name'] ?? 'Provider', style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(provider['businessName'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: AppColors.warning),
                const SizedBox(width: 2),
                Text('${(provider['rating'] ?? 0.0)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTile(Map<String, dynamic> service) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.booking, arguments: {
        'providerId': service['providerId'],
        'serviceId': service['id'],
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.miscellaneous_services, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                  if ((service['description'] ?? '').isNotEmpty)
                    Text(service['description'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Text('₹${((service['price'] ?? 0) as num).toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
