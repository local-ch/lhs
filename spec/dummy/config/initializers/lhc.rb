LHC.configure do |config|
  config.interceptors = [LHS::ExtendedRollbar]
end
