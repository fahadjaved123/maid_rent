import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maid_rent/config/constants.dart';
import 'package:maid_rent/config/theme.dart';
import 'package:maid_rent/models/maid_profile_model.dart';
import 'package:maid_rent/models/service_category.dart';
import 'package:maid_rent/providers/maid_provider.dart';
import 'package:maid_rent/widgets/empty_state_widget.dart';
import 'package:maid_rent/widgets/loading_widget.dart';
import 'package:maid_rent/widgets/maid_card.dart';

class BrowseMaidsScreen extends StatefulWidget {
  final String? initialService;

  const BrowseMaidsScreen({super.key, this.initialService});

  @override
  State<BrowseMaidsScreen> createState() => _BrowseMaidsScreenState();
}

class _BrowseMaidsScreenState extends State<BrowseMaidsScreen> {
  final _searchController = TextEditingController();
  String? _selectedService;
  double _minRating = 0.0;
  double _maxHourlyRate = 2000.0;
  bool _hourlyOnly = false;
  bool _monthlyOnly = false;
  String _sortBy = 'rating'; // rating, price_low, price_high, experience

  @override
  void initState() {
    super.initState();
    _selectedService = widget.initialService;
    _loadMaids();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMaids() async {
    context.read<MaidProvider>().loadAvailableMaids();
  }

  List<MaidProfileModel> _filterMaids(List<MaidProfileModel> maids) {
    return maids.where((maid) {
      // Search query
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        final nameMatches =
            (maid.name ?? '').toLowerCase().contains(query);
        final bioMatches = maid.bio.toLowerCase().contains(query);
        final serviceMatches = maid.specializedServices
            .any((s) => s.toLowerCase().contains(query));
        if (!nameMatches && !bioMatches && !serviceMatches) return false;
      }

      // Service filter
      if (_selectedService != null &&
          !maid.categories.any((cat) => cat.label == _selectedService) &&
          !maid.specializedServices.contains(_selectedService)) {
        return false;
      }

      // Rating filter
      if (maid.rating < _minRating) return false;

      // Price filter
      if (maid.hourlyRate > _maxHourlyRate) return false;

      // Hiring type filter
      if (_hourlyOnly && !maid.acceptsHourly) return false;
      if (_monthlyOnly && !maid.acceptsMonthly) return false;

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_sortBy) {
          case 'price_low':
            return a.hourlyRate.compareTo(b.hourlyRate);
          case 'price_high':
            return b.hourlyRate.compareTo(a.hourlyRate);
          case 'experience':
            return b.experienceYears.compareTo(a.experienceYears);
          case 'rating':
          default:
            return b.rating.compareTo(a.rating);
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Maids'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by name, service, or bio...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Service Filter Chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'All Services',
                  isSelected: _selectedService == null,
                  onTap: () => setState(() => _selectedService = null),
                ),
                ...AppConstants.serviceTypes.map((service) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _FilterChip(
                      label: service,
                      isSelected: _selectedService == service,
                      onTap: () => setState(() {
                        _selectedService =
                            _selectedService == service ? null : service;
                      }),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Results
          Expanded(
            child: Consumer<MaidProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const LoadingWidget(message: 'Finding maids...');
                }

                final filteredMaids =
                    _filterMaids(provider.availableMaids);

                if (filteredMaids.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.search_off,
                    title: 'No Maids Found',
                    subtitle:
                        'Try adjusting your search criteria or filters to find more results.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadMaids,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredMaids.length,
                    itemBuilder: (context, index) {
                      final maid = filteredMaids[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MaidCard(
                          maid: maid,
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/household/maid-detail',
                            arguments: maid.uid,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter & Sort',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setModalState(() {
                        _minRating = 0.0;
                        _maxHourlyRate = 2000.0;
                        _hourlyOnly = false;
                        _monthlyOnly = false;
                        _sortBy = 'rating';
                      });
                      setState(() {});
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // Sort By
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _SortOption(
                    label: 'Rating',
                    value: 'rating',
                    groupValue: _sortBy,
                    onChanged: (val) {
                      setModalState(() => _sortBy = val);
                      setState(() {});
                    },
                  ),
                  _SortOption(
                    label: 'Price: Low to High',
                    value: 'price_low',
                    groupValue: _sortBy,
                    onChanged: (val) {
                      setModalState(() => _sortBy = val);
                      setState(() {});
                    },
                  ),
                  _SortOption(
                    label: 'Price: High to Low',
                    value: 'price_high',
                    groupValue: _sortBy,
                    onChanged: (val) {
                      setModalState(() => _sortBy = val);
                      setState(() {});
                    },
                  ),
                  _SortOption(
                    label: 'Experience',
                    value: 'experience',
                    groupValue: _sortBy,
                    onChanged: (val) {
                      setModalState(() => _sortBy = val);
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Minimum Rating
              Text(
                'Minimum Rating: ${_minRating.toStringAsFixed(1)} ★',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Slider(
                value: _minRating,
                min: 0.0,
                max: 5.0,
                divisions: 10,
                label: _minRating.toStringAsFixed(1),
                activeColor: AppTheme.primaryColor,
                onChanged: (val) {
                  setModalState(() => _minRating = val);
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),

              // Maximum Hourly Rate
              Text(
                'Max Hourly Rate: Rs. ${_maxHourlyRate.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Slider(
                value: _maxHourlyRate,
                min: 100.0,
                max: 3000.0,
                divisions: 29,
                label: 'Rs. ${_maxHourlyRate.toStringAsFixed(0)}',
                activeColor: AppTheme.primaryColor,
                onChanged: (val) {
                  setModalState(() => _maxHourlyRate = val);
                  setState(() {});
                },
              ),
              const SizedBox(height: 12),

              // Hiring Type Checkboxes
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Available for Hourly Jobs'),
                value: _hourlyOnly,
                onChanged: (val) {
                  setModalState(() => _hourlyOnly = val!);
                  setState(() {});
                },
                activeColor: AppTheme.primaryColor,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Available for Monthly Hiring'),
                value: _monthlyOnly,
                onChanged: (val) {
                  setModalState(() => _monthlyOnly = val!);
                  setState(() {});
                },
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(height: 20),

              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final String label;
  final String value;
  final String groupValue;
  final ValueChanged<String> onChanged;

  const _SortOption({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onChanged(value),
      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
    );
  }
}
